#!/bin/bash

# Parameters
MCR_path="/home/labs/bfreich/maork/CoSMIC_for_SMURF/MATLAB/MATLAB_Runtime/v97/"
old_db_fasta="/home/labs/bfreich/CollaborationRavid/Database_enrichment/Update_30082023_2/old_databse/Silva_with_LNA.fasta"
added_db_fasta="/home/labs/bfreich/shaharr/microbiome_paper/For_revision/run_scripts_on_plant_samples/enrich_db/Seqs_to_add_to_db.fasta"
new_db_dir_name="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/augmented_dB_Plants/"
new_db_file_name="database_augmented_mock_Plants"

# Command
"/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/ADD_ENTRIES/add_entries_to_db_for_Arik/for_redistribution_files_only/run_add_entries_to_db_for_Arik.sh" \
$MCR_path \
$old_db_fasta \
$added_db_fasta \
$new_db_dir_name \
$new_db_file_name
