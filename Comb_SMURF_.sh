#!/bin/bash

# Base directory where subfolders are located
baseDir="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/combinatorial_primer_selection/"

# Variable for experiment name prefix
expName="Master_tutorial"

# Master file path containing the files to copy
masterFilePath="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/${expName}/data_${expName}/"

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
