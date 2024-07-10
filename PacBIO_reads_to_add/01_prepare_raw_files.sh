#!/bin/bash
# before running the script: 1. Make sure you have a running miniconda/conda packge installed (or loaded the packages in the Weizmann cluster)
#                            2. install the proper packages in a dedicated conda environment
# 
# To run the script use the follwing syntax, to avoid issues of repeatibility provide full paths for each file 
# ./01_prepare_raw_files.sh "primer_file_path" "long_read_sequences_path" "sample_name" "r_script_path" "path_to_data_base"

# primer_file_path = "/home/labs/bfreich/shaharr/microbiome_paper/For_revision/Enrich_database_code/primers_rc.fasta"
# long_read_sequences_path = "/home/labs/bfreich/shaharr/PacBio/All_raw_fastas/raw_for_pipeline/Arava.fastq.gz"
# sample_name = "Arava"
# r_script_path = "/home/labs/bfreich/shaharr/microbiome_paper/For_revision/Enrich_database_code/reads_per_region.R"
# path_to_data_base = "/home/labs/bfreich/CollaborationRavid/Database_enrichment/Update_30082023_2/old_databse/Silva_with_LNA.fasta"

set -e

# if working on the Weizmann cluster load the following packges:
module load cd-hit/4.8.1
module load cutadapt/4.2-GCCcore-11.3.0
module load seqkit/2.3.1
module load R/4.0.0
module load seqtk/1.3-GCC-8.3.0
module load BBMap

# ready script for sending to the weizmann cluster
# bsub -q new-short -R "rusage[mem=1000]" -R "span[hosts=1]" -n 50 -J prepare -o prepare.out -e prepare.err ./01_prepare_raw_files.sh \
#         "/home/labs/bfreich/shaharr/microbiome_paper/For_revision/Enrich_database_code/primers_rc.fasta" \
#         "/home/labs/bfreich/shaharr/PacBio/All_raw_fastas/raw_for_pipeline/Arava.fastq.gz" \
#         "Arava" \
#         "/home/labs/bfreich/shaharr/microbiome_paper/For_revision/Enrich_database_code/reads_per_region.R" \
#         "/home/labs/bfreich/CollaborationRavid/Database_enrichment/Update_30082023_2/old_databse/Silva_with_LNA.fasta" 


# if working with conda, create a conda environment 
## 1. conda create -n enrich_db
# activate it
## 2. conda activate enrich_db
# install the following packges:
## 3. conda install bioconda::cd-hit=4.8.1 bioconda::cutadapt=4.2 bioconda::seqtk=1.3 r-essentials r-base bioconda::seqkit=2.3.1 bioconda::bbmap=38.45

#activating the environment
# source activate enrich_db

primers=$1
seqs=$2
name=$3
r_script=$4
db=$5

#2. Run cutadapt with the primer file using the following code, to demultiplex long reads according to the primers and remove reads that do
##  not match any primer

echo "running cutadapt to find only reads that matches the LNA primers"
cutadapt  \
        --no-indels \
        -g file:$primers \
        -o {name}.fastq \
        --action=retain \
        --rc \
        $seqs &>>"$name"_log.txt

#3. reverse complement sequences which only contain the reverse primer

echo "Arranging all sequences to the same directionality"
for j in $(ls Rev*)
do
        seqkit seq $j -g -r -p -o "RC_"$j
done 

#4. Add a tag to the header of sequences who contatains only one primer

echo "Adding idintifirers to the reads headers"
for k in $(ls Fwd*fastq | grep -Ev "Comp")
do      
        sed -i 's/ccs/ccs_fwd_only/g' $k
done

for k in $(ls RC*)
do      
        sed -i 's/ccs/ccs_reverse_only/g' $k
done

#5. concatenate all regions to one file 
echo "Concatenating all matching reads to one file"
cat Fwd* RC* > All_sequences.fastq

#6. Trasnform to fasta file using bbmap
echo "Arranging as proper fasta file"
# reformat.sh in=All_sequences.fastq out=All_sequences.fasta -da fastawrap=0
sed -n '1~4s/^@/>/p;2~4p' All_sequences.fastq > All_sequences.fasta

#7. replace spaces to underscores
cat All_sequences.fasta | sed 's/ /_/g' > All_sequences_linearized.fasta

##to get stats about length "cat All_sequences_linearized.fasta | seqkit seq | seqkit stats"

#8.filter by length - bigger than 1100 and smaller than 4000
##using bbmap, loaded by default
echo "Filtering sequences by length, minlength 1000 and maxlength 4000, similar to the SILVA database"
reformat.sh in=All_sequences_linearized.fasta out="$name"_All_sequences_length_filtered.fasta minlength=1100 maxlength=4000

#9. print stats
echo "Calculating stats"
cat All_sequences_linearized.fasta | seqkit seq | seqkit stats > length_before_trimming.txt
cat "$name"_All_sequences_length_filtered.fasta | seqkit seq | seqkit stats > length_after_trimming.txt
zcat $seqs | seqkit seq | seqkit stats > length_raw_file.txt
cat *log.txt | grep -E -A 2 "Adapter" > sequences_per_region.txt
sed -E 's/=== | ===|--//g' sequences_per_region.txt | grep -Ev "^$" | sed 'N;s/\n/; /' | sed -E "s/ [t|T]rimmed| 5' trimmed: [0-9]+ times;| 3'| 5'| times|:|;//g" > mod_report_file.txt
Rscript $r_script $name

echo "FINSHED PREPARING READS, NOW LETS CLUSTER !!"

#10. clustering sequences to remove redundancy, for each cluster only its seed sequence is kept
echo "Clustering sequences to remove redundancy in the sample"
cd-hit-est -i "$name"_All_sequences_length_filtered.fasta -o all_clustered.99.fasta -c 0.99 -n 10 -d 0 -M 0 -r 0 -g 1 -T 0

#11. clustering seed sequences agaist the "old" database and keeping sequences < 97% identity (time consuming step, use many cores)
echo "Comparing all cluster seed sequences to the database, outputing the ones that do not match as new 16S sequences"
cd-hit-est-2d \
    -i $db \
    -i2 all_clustered.99.fasta \
    -o cd_hit_2d_clustered_2.97.fasta -c 0.97 -n 10 -g 1 -d 0 -M 0 -r 0 -T 0


#12. Create an original header to new header tab dilimited file (in this case each header gets running numbers starting from 2000000)
echo "Reformating files"
grep -E "^>" cd_hit_2d_clustered_2.97.fasta | sed 's/>//g' | awk 'BEGIN{ FS = OFS = "\t" } { print $0, (NR+1999999) }' > original_headers_2.txt 

#13. create a new fasta file with new header names
seqkit replace -p '(m.*)$' -r '{kv}' -k original_headers_2.txt cd_hit_2d_clustered_2.97.fasta > Sequences_to_add_non_linear.fasta

#14. linearize sequences 
seqtk seq -l 0 Sequences_to_add_non_linear.fasta > Seqs_to_add_to_db.fasta

echo "FINISHED !!!, Use the ---Seqs_to_add_to_db.fasta---, it contains the sequences that are new to the database"