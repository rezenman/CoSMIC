import os
import shutil
import itertools
from pathlib import Path

# Specify the base parameters
master_file_path = "/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/Master_tutorial/data_Master_tutorial/"
experiment_name = "Master_tutorial"
base_dir = "combinatorial_primer_selection"
regions = [1,2,3,4,5,6]  # Specify your regions here

# Calculate all unique combinations of the regions
combinations = []
for r in range(1, len(regions) + 1):
    combinations.extend(itertools.combinations(regions, r))

# Pre-clean-up: Remove the existing directory to start fresh
shutil.rmtree(base_dir, ignore_errors=True)

# Create the main directory
Path(base_dir).mkdir(parents=True, exist_ok=True)

# Generate subfolders and populate them
actual_subfolders = 0
for combo in combinations:
    folder_name = f"{experiment_name}_{'_'.join(map(str, combo))}"
    folder_path = os.path.join(base_dir, folder_name, f"data_{folder_name}")
    Path(folder_path).mkdir(parents=True, exist_ok=True)
    # Copy files from masterFilePath to the new subfolder
    # Replace this with the actual file copying logic if more specific actions are needed
    for item in Path(master_file_path).glob('*'):
        if item.is_file():
            shutil.copy(item, folder_path)
    actual_subfolders += 1

print(f"Actual number of subfolders created: {actual_subfolders}")
