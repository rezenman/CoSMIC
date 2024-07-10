#!/bin/bash

baseDir="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/combinatorial_primer_selection/"
wrapperScriptPath="/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/SMURF/wrapper_SMURF/for_redistribution_files_only/run_wrapper_SMURF.sh"
MCR_path="/home/labs/bfreich/maork/CoSMIC_for_SMURF/MATLAB/MATLAB_Runtime/v97/"
queue="new-short"
memUsage="rusage[mem=32GB]"
batchSize=20

# Variable for experiment name prefix
expName="Master_tutorial"

cd "$baseDir" || { echo "Failed to change directory to $baseDir. Exiting."; exit 1; }

submitJobs() {
    local jobCount=0
    local jobNames=()

    for folderName in *; do
        if [[ -d "$folderName" && $folderName == "${expName}"* ]]; then
            # Extracts the regions after the experiment name prefix, replacing underscores with commas
            local regions=$(echo "$folderName" | sed -e "s/^.*${expName}_//" -e 's/_/,/g')
            local jobName="SMURF_${regions//,/}"

            # Update paths for output and error files to be within the subfolder
            local outputFile="${baseDir}/${folderName}/${jobName}.o"
            local errorFile="${baseDir}/${folderName}/${jobName}.e"
            local runFilePath="${baseDir}/${folderName}/run_file"

            # Submit job
            bsub -q "$queue" -J "$jobName" -o "$outputFile" -e "$errorFile" -R "$memUsage" "$wrapperScriptPath" "$MCR_path" "$runFilePath"
            jobNames+=("$jobName")

            ((jobCount++))

            # Check if batch limit is reached
            if [[ $jobCount -ge $batchSize ]]; then
                waitForJobs "${jobNames[@]}"
                jobNames=() # Reset for next batch
                jobCount=0
            fi
        fi
    done

    # Wait for any remaining jobs from the last batch
    if [[ $jobCount -gt 0 ]]; then
        waitForJobs "${jobNames[@]}"
    fi
}

waitForJobs() {
    local jobs=("$@")
    echo "Waiting for jobs to finish: ${jobs[*]}"

    while true; do
        local allDone=true

        for jobName in "${jobs[@]}"; do
            if bjobs -w | grep -q "$jobName"; then
                allDone=false
                break
            fi
        done

        if $allDone; then
            echo "All jobs in batch finished"
            break
        else
            sleep 60 # Adjust sleep time as needed
        fi
    done
}

submitJobs
