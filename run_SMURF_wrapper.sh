#!/bin/bash

# Define parameters for run file
cover_dir="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/"
ExpName="Master_tutorial"
primer_set_file="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/CoSMIC_paper_primers"  # Ensure this does not include .csv
new_db_dir_name="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/augmented_dB_Plants"
db_name="database_augmented_mock_Plants"
database_len=200
REGIONS="1:10"
kmer_len=135

# Define run file path
run_file="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/run_file"

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
MCR_path="/home/labs/bfreich/maork/CoSMIC_for_SMURF/MATLAB/MATLAB_Runtime/v97/"

# Command execution
"/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/SMURF/wrapper_SMURF/for_redistribution_files_only/run_wrapper_SMURF.sh" \
$MCR_path \
$run_file
