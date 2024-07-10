#!/bin/bash

# Define parameters
MCR_path="/home/labs/bfreich/maork/CoSMIC_for_SMURF/MATLAB/MATLAB_Runtime/v97/"
primer_set_file="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/CoSMIC_paper_primers"
new_db_dir_name="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/augmented_dB_Plants/"
db_filename="database_augmented_mock_Plants.mat"
database_len=200
parallel_settings_path="/home/labs/bfreich/maork/.matlab/R2019b/parallel.mlsettings"

# Command execution
"/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/CREATE_SMURF_DB/create_SILVA_SMURF_db/for_redistribution_files_only/run_create_SILVA_SMURF_db.sh" \
$MCR_path \
$primer_set_file \
$new_db_dir_name \
$db_filename \
$database_len \
-mcruserdata ParallelProfile:$parallel_settings_path
