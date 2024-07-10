

# CoSMIC Tutorial and Code

This tutorial outlines all usage aspects of the Comprehensive Small Ribosomal Subunit Mapping and Identification of Communities (CoSMIC) approach presented by Knafo & Resenman et al., "***CoSMIC - A hybrid approach for large-scale high-resolution microbial profiling of novel niches***". CoSMIC uses long- and short-reads to provide a cost-effective and high-resolution 16S rRNA microbial profiling of niches that are less explored compared, e.g., to human-associated niches. 

More specifically, this tutorial covers:

- Data requirements 
- Installation prerequisites
- All steps in the CoSMIC pipeline (detailed below).

This tutorial assumes the user performs the full CoSMIC pipeline. More specifically, we consider the following steps:

1. [Preparing](#preparing-the-16s-rrna-sequences-to-augment-the-database) long-read 16S rRNA gene sequences to be augmented to an existing database.
2. [Adding novel full-length 16S rRNA sequences to the database](#augmenting-the-database-with-new-16s-rrna-sequences).
3. [Preparing the augmented database in a SMURF-like manner](#preparing-the-augmented-database-for-cosmic-analysis), i.e., considering a specific set of primer pairs.
4. [Denoising and demultiplexing](#preparing-the-augmented-database-for-cosmic-analysis) of Illumina short reads from the samples to be profiled. 
5. [Running SMURF](#executing-smurf-with-denoised-reads-and-an-augmented-database) based on the augmented database and using denoised reads. 

We also provide the code for [comparing results of different subsets of primer pairs](#combinatorial-primer-set-evaluation). 

Each step provides both code and example data.``` We strongly suggest to start by running the provided scripts using the examples to validate that all prerequisites are met```. 



## Prerequisites

### Data Requirements:

- A database of full-length 16S rRNA sequences (e.g., `SILVA`). To download use this link: https://www.dropbox.com/scl/fi/auzrz9vrx731czvkest09/Silva_with_LNA.fasta?rlkey=8ovt09qv13ubg1hed5k06o8ed&dl=0
- `Full-length 16S rRNA sequences` to be added to the database: Long reads generated by, e.g., PacBio sequencing using our LNA primers (see manucsript), or full-length 16S rRNA sequences collected by other means. The file should be in `FASTQ format`. 
- A list of `primer pairs` that were used to PCR amplify the sequenced samples (e.g. Swift's 16S SNAP panel).
- `Paired-end Illumina short reads` from the relevant sample set.


## Installation

First, install the necessary dependencies using Conda and provided YAML file **CoSMIC_environment.yml**:

```
conda env create -f CoSMIC_environment.yml
conda activate CoSMIC_analysis_env
```

A detailed YAML file, **CoSMIC.yaml**, explains the dependencies and the versions of the packages used in the tutorial, as well as cmd examples. 

Also, install the MATLAB Compiler Runtime (MCR). The version used in the tutorial is v97 and can be downloaded at the following link: https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/4/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_4_glnxa64.zip.

## Preparing the 16S rRNA sequences by which to augment the Database

The **01_prepare_raw_files.sh** script processes PacBio-generated long reads for microbiome studies. It first demultiplexes the reads based on primers, then adjusts their directionality and modifies their headers for identification. It concatenates and converts these reads into a single FASTA file, which is then filtered to retain sequences between `1100 and 4000 nt` in length, aligning with standards for genomic databases like SILVA. The script also removes redundancy by clustering sequences and comparing them against a reference database to identify novel 16S rRNA sequences. Finally, it reformats headers and arranges reads in the correct 5' to 3' sequence, producing a file with new sequences to the database.

Scripts and files are provided in the subfolder **PacBIO_reads_to_add**.

⚠️ Note that sequences to add must be entered in FASTQ format.⚠️
```
primer_file_path = "/path/to/primers_rc.fasta" # The path to the primer file (generic full length 16S primers as provided in methods) 
long_read_sequences_path = "/path/to/Arava.fastq.gz" # The path to the PacBio long reads file
sample_name = "Arava" # The name of the sample chosen by the user
r_script_path = "/path/to/reads_per_region.R" # The path to the R script
path_to_database = "/path/to/Silva_with_LNA.fasta" # The path to the old database to cluster against
```

Run the cmd with the correct paths and variables ⚠️(make sure you change the generic paths provided)⚠️:

```bash
./01_prepare_raw_files.sh "/path/to/primers_rc.fasta" "/path/to/Arava.fastq.gz" "Arava" "/path/to/reads_per_region.R" "/path/to/Silva_with_LNA.fasta" 
```

This command will result in a FASTA file containing sequences to be added to the current DB - **Seqs_to_add_to_db.fasta**
and multiple intermediate files so we would advise running it in a new directory.

## Augmenting the Database with New 16S rRNA Sequences
After preparing a file with novel 16S rRNA sequences (e.g., **Seqs_to_add_to_db.fasta**), the next step involves integrating these sequences into the original database (e.g., SILVA), and creating an augmented version. To facilitate this, we employ the **run_add_entries.sh** script.

Edit **run_add_entries.sh** script: Open the script in a text editor, update the following parameters with your specific paths and make sure the directoty exists before running:

```#!/bin/bash
# Parameters
MCR_path="/path/to/MATLAB_Runtime/v97/" # This matlab compiler runtime is needed for the next step and can be downloaded from the Mathworks website
old_db_fasta="/path/to/Silva_with_LNA.fasta" # The original database
added_db_fasta="/path/to/Seqs_to_add_to_db.fasta" # The new sequences to add to the database
new_db_dir_name="/path/to/augmented_dB_Plants/" # The directory to save the new database
new_db_file_name="database_augmented_mock_Plants" # The name of the new database

# Command
"/path/to/add_entries_to_db_for_Arik.sh" \
$MCR_path \
$old_db_fasta \
$added_db_fasta \
$new_db_dir_name \
$new_db_file_name
```

Run the modified command:

```
bash run_add_entries.sh
```

This command should result in a new augmented DB.

## Formatting the Augmented Database for CoSMIC Analysis

To make the augmented database compatible with CoSMIC (and SMURF), it must be processed according to the specific primer pairs used in your experiments. This involves using the **run_create_SMURF_db.sh** script to format the database appropriately.

First, make sure that all required paths in the **run_create_SMURF_db.sh** script are correctly set to match your environment and files:
```
#!/bin/bash

# Define parameters
MCR_path="/path/to/MATLAB_Runtime/v97/" # This matlab compiler runtime is needed for the next step and can be downloaded from the Mathworks website
primer_set_file="/path/to/CoSMIC_paper_primers" # The primer set file. Make sure the ".csv" suffix does not NOT appear in the file's  name
new_db_dir_name="/path/to/augmented_dB_Plants/" # The dir where the augmented DB is located
db_filename="database_augmented_mock_Plants.mat" # The name of the new database formatted for CoSMIC in matlab format (see former step)
database_len=200
parallel_settings_path="/path/to/parallel.mlsettings" # The parallel settings file generated by matlab when parallel processing is used. For the sake of computing time, the number of workers should match the number of primer pairs (the code prepares a SMURF database per primer pair)

# Command execution
"/path/to/create_SILVA_SMURF_db.sh" \
$MCR_path \
$primer_set_file \
$new_db_dir_name \
$db_filename \
$database_len \
-mcruserdata ParallelProfile:$parallel_settings_path

```
Ideally, the number of cores needed for parallel processing equals the number of primer pairs by which reconstruction is performed. ```In the tutorial n=10```. Run the following command:

```
bash run_create_SMURF_db.sh
```
### Troubleshooting

- MATLAB Runtime Compatibility: Verify that the specified MATLAB Compiler Runtime version is installed.
- Primer File Format: Make sure that the primer set file is correctly formatted and named as instructed, particularly noting the absence of a ".csv" suffix.
- Parallel Processing Setup: Double-check the parallel settings file and your computational environment to match the required number of cores for efficient processing.

## Denoising Illumina Short Reads before applying SMURF

The script **Prepare_samples_for_smurf.sh** aims to denoise short paired-end Illumina reads using the DADA2 algorithm, demultiplex them into their corresponding primer pairs, and maintain read frequency. This process generates R1 and R2 read files, ready for SMURF analysis.

The bash script needed is **Prepare_samples_for_smurf.sh** and the following parameters and paths need to be altered for each sample. Scripts and files appear in the subfolder **illumina_sample**.
```
path_to_R1="/path/to/S474_R_S179_R1_001.fastq.gz" # The path to the R1 read file
path_to_R2="/path/to/S474_R_S179_R2_001.fastq.gz" # The path to the R2 read file
path_to_for_primer="/path/to/primers_16S_V1-9_anchored_for.fasta" # The path to the forward primer file
path_to_rev_primer="/path/to/primers_16S_V1-9_anchored_rev.fasta" # The path to the reverse primer file
path_to_dada_script="/path/to/dada2_all_script.R" # The path to the dada2 script
path_to_fasta_to_fastq_script="/path/to/fasta_to_fastq.pl" # The path to the fasta to fastq script
sample_name="S474R" # The name of the sample chosen by the user

```

Then, run the command in the following way:

```
./Prepare_samples_for_smurf.sh "path_to_R1" "path_to_R2" "path_to_for_primer" "path_to_rev_primer" "path_to_dada_script" "path_to_fasta_to_fastq_script" "sample_name"
```
This command will create a subdirectory named after the sample containing the processed read files. Make sure each sample results in two correctly named read files. Naming convention is: ```SampleName_L001_R1_001.fastq.gz``` and ```SampleName_L001_R2_001.fastq.gz```.

### Important to verify:

- Naming Convention: Adhering to the specified naming format is crucial for seamless integration into subsequent analysis steps.
- Sample Files: For the tutorial, this step has been completed for all samples. Processed samples are located in **/Master_tutorial/data_Master_tutorial/**, with the experiment name Master_tutorial and the samples within the data_Master_tutorial folder. Ensure the sample directory prefix matches data_EXP_NAME.

⚠️ Maintaining consistent naming and file organization is critical for the success of downstream analysis steps, especially when integrating with the SMURF pipeline.⚠️

## Running SMURF with Denoised Reads and an Augmented Database

To analyze your denoised reads using SMURF based on the augmented database, configure the **run_SMURF_wrapper.sh** script with the specific details of your experimental setup.

More specifically, set the following parameters to reflect your experimental setup and file locations:
```
#!/bin/bash

# Define parameters of run file
cover_dir="/path/to/CoSMIC/" # The path to the CoSMIC directory
ExpName="Master_tutorial" # The name of the experiment
primer_set_file="/path/to/CoSMIC_paper_primers"  # make sure there is NO ".csv" suffix 
new_db_dir_name="/path/to/augmented_dB_Plants/" # The dir where the augmented DB is located
db_name="database_augmented_mock_Plants" # The name of the new database formatted for CoSMIC in matlab format
database_len=200 # The length of the database or MAX read length
REGIONS="1:10" # The regions to be used in the analysis in matlab format [1:10]
kmer_len=135 # The length of the kmer to be used in the analysis

# Define run file path
run_file="/path/to/run_file"

# Create run file with parameters
echo "cover_dir = '$cover_dir';" > $run_file
echo "ExpName = '$ExpName';" >> $run_file
echo "primer_set_file = '$primer_set_file';" >> $run_file
echo "new_db_dir_name = '$new_db_dir_name';" >> $run_file
echo "db_name = '$db_name';" >> $run_file
echo "database_len = $database_len;" >> $run_file
echo "REGIONS = $REGIONS;" >> $run_file
echo "kmer_len = $kmer_len;" >> $run_file

# MATLAB Runtime path
MCR_path="/path/to/MATLAB_Runtime/v97/"

# Command execution
"/path/to/wrapper_SMURF.sh" \
$MCR_path \
$run_file

```
This script will generate a run file for a given experiment and perform SMURF on all the sample subfolders in ```data_Master_tutorial``` by running the following command:
```
bash run_SMURF_wrapper.sh
```

This command generates a run file tailored to your experiment and applies SMURF across all denoised sample subfolders within the ```data_Master_tutorial``` directory.

The ```REGIONS="1:10"``` parameter specifies the sets of primer pairs by which reconstruction is performed (corresponding to the primer pairs in, e.g., ```CoSMIC_paper_primers``` ). Adjust this based on the regions covered by your primer sets and the specific needs of your study to ensure comprehensive analysis.


### Output and Results

Upon completion, the script generates a new Results folder containing:
- ***ReadCountStats_Results***: A report detailing the number of aligned reads per region among other statistics.
- ***GROUPS_Results***: An aggregated summary of bacterial abundances across samples.
- A Groups folder containing a FASTA file for each group, comprising all pertinent sequence headers.


## Combinatorial Primer set Evaluation 

### Creating and populating folders for each Primer-set Combination 

Evaluating different primer set combinations allows for discarding primer pairs whose contribution to detection and resolution is minimal. The following code performs SMURF over each subset of primer pairs. Due to the computational intensity of this process, careful preparation and execution are necessary.

**Comb_SMURF.py** is a Python script designed to generate a subfolder for each chosen primer combination within a specified base directory. To adapt the script to your needs, adjust the following parameters accordingly:

```
# Specify the base parameters
master_file_path = "/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/Master_tutorial/data_Master_tutorial/" # The path to the master file
experiment_name = "Master_tutorial" # The name of the experiment
base_dir = "combinatorial_primer_selection" # The base directory where the subfolders will be created
regions = [1,2,3,4,5,6]  # Specify your regions here 
```

To create the subfolders, execute the modified script:

```
python Comb_SMURF.py
```

After subfolders are created use the bash script - **Comb_SMURF_.sh** which populates the subfolders with the relevant data. ```It is crucial to make sure that the master folder contains read files```. If there is a SMURF output it will also be duplicated hampering further analysis.
Change the paths in the bash script and make sure the paths are correct:


```
#!/bin/bash

# Base directory where subfolders are located
baseDir="~CoSMIC/combinatorial_primer_selection/"

# Variable for experiment name prefix
expName="Master_tutorial"

# Master file path containing the files to copy
masterFilePath="~/CoSMIC_for_SMURF/CoSMIC/${expName}/data_${expName}/"

# Navigate into the base directory
cd "$baseDir" || exit

# Loop through each subfolder in the base directory
for folderName in *; do
    if [[ -d "$folderName" && "$folderName" == "${expName}_"* ]]; then
        # Extract the regions from the folder name
        # Assumes folder names are formatted like "Master_tutorial_3_5_6"
        regions=$(echo "$folderName" | sed -e "s/^${expName}_//" -e 's/_/,/g')
        # Transform regions into MATLAB array format [3,5,6]
        matlab_regions="[$regions]"

        # Copy the contents from masterFilePath to the subfolder
        mkdir -p "$folderName/data_$folderName"
        cp -r "$masterFilePath"* "$folderName/data_$folderName/"
        
        # Define the full path for cover_dir correctly
        cover_dir="$baseDir"

        # Generate the run file for each subfolder
        run_file="$folderName/run_file"
        cat > "$run_file" <<- EOF
cover_dir = '$cover_dir';
ExpName = '$folderName';
primer_set_file = '/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/CoSMIC_paper_primers';
new_db_dir_name = '/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/augmented_dB_Plants/';
db_name = 'database_augmented_mock_Plants';
database_len = 200;
REGIONS = $matlab_regions;
kmer_len = 135;
EOF

    fi
done


```
This script will generate a run file for each subfolder, which will be used to run SMURF for each subset of primer pair set against the updated database,
as well as copy the Illumina reads to the subfolder.

Run the following command to populate the subfolders:
```
bash Comb_SMURF_.sh
```

### Running SMURF on Primer Combinations
Execute SMURF for each primer set permutation against the updated database. 

The following script **Run_COMB_SMURF_batches.sh** will iterate through subfolders submitting batches of 20 jobs at a time to an LSF cluster. Make sure to provide the correct path for MCR and wrapper:

It will submit a job for each subfolder in the "combinatorial_primer_selection" directory, running SMURF for each subset of primer pairs, using the augmented database. It will run 50 jobs at a time, waiting for each batch to complete before submitting the next batch.
You should edit this file with specific LSF parameters for your cluster.

```
#!/bin/bash

baseDir="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/combinatorial_primer_selection/" # The base directory where the subfolders are located
wrapperScriptPath="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/SMURF/wrapper_SMURF/for_redistribution_files_only/run_wrapper_SMURF.sh" # The path to the wrapper script
MCR_path="/home/labs/bfreich/maork/CoSMIC_for_SMURF/MATLAB/MATLAB_Runtime/v97/" # The path to the MATLAB Compiler Runtime
queue="new-short" # The queue to submit the jobs to
memUsage="rusage[mem=32GB]" # The memory usage for each job
batchSize=20 # The number of jobs to submit at a time

cd "$baseDir" || exit

submitJobs() {
```

Run the following command to execute the script:
```
bash Run_COMB_SMURF_batches.sh
```
### Generating the Analysis Report for Primer Combinations

Analyze the performance of each primer set combination, highlighting the reduction in ambiguity, and finding the optimal set of primer pairs. The report also includes unassigned read counts to indicate whether additional LNA long-read sequencing is necessary:

```python
python Multi_region_report.py -input /results_primers -o report.html
```