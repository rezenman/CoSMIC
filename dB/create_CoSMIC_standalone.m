% create database
clear
addpath('/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/dB/')


% add entries to database
old_db_fasta = '/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/dB/mock_SILVA.fasta'
added_db_fasta = '/home/labs/bfreich/maork/CoSMIC_for_SMURF/CoSMIC/dB/mock_added_seqs.fasta';
new_db_dir_name = '/home/shental/6Reg/Experiment/CoSMIC/dB/augmented_dB_2/';
new_db_file_name = 'database_augmented_mock_2';
add_entries_to_db_for_Arik(old_db_fasta,added_db_fasta,new_db_dir_name,new_db_file_name)

% required mcr
% https://ssd.mathworks.com/supportfiles/downloads/R2019b/Release/4/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2019b_Update_4_glnxa64.zip

% command
% /home/shental/6Reg/Experiment/CoSMIC/ADD_ENTRIES/add_entries_to_db_for_Arik/for_redistribution_files_only/run_add_entries_to_db_for_Arik.sh /opt/apps/matlab/Runtime/v97/ /home/shental/6Reg/Experiment/CoSMIC/dB/mock_SILVA.fasta /home/shental/6Reg/Experiment/CoSMIC/dB/mock_added_seqs.fasta /home/shental/6Reg/Experiment/CoSMIC/dB/augmented_dB/ database_augmented_mock 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create SMURF/CoSMIC db for a certain primer pair 
clear
primer_set_file = '/home/shental/6Reg/Experiment/CoSMIC/qiagen_primers'; % this is a csv file (make sure the file name DOES NOT include .csv)
new_db_dir_name = '/home/shental/6Reg/Experiment/CoSMIC/dB/augmented_dB/';
db_filename = 'database_augmented_mock.mat';
database_len = 200;
create_SILVA_SMURF_db(primer_set_file,new_db_dir_name,db_filename,database_len);


% command - using parallel toolbox
% you should locate /path/to/myClusterProfile.mlsettings
% then replace "/home/shental/.matlab/R2019b/parallel.mlsettings"
% by your output

% /home/shental/6Reg/Experiment/CoSMIC/CREATE_SMURF_DB/create_SILVA_SMURF_db/for_redistribution_files_only/run_create_SILVA_SMURF_db.sh /opt/apps/matlab/Runtime/v97/  /home/shental/6Reg/Experiment/CoSMIC/qiagen_primers /home/shental/6Reg/Experiment/CoSMIC/dB/augmented_dB/ database_augmented_mock.mat 200 -mcruserdata ParallelProfile:/home/shental/.matlab/R2019b/parallel.mlsettings


% reconstruct qiagen


% prerequisites: 
% 1. assume: post DADA2; 
% 2. file name convention: a directory that cotains subdirectories, each named by the sample name. 
%          exapmle:dirname S96R_S91 contains files S96R_S91_L001_R1_001.fastq.gz  S96R_S91_L001_R2_001.fastq.gz
% fastq files must be named SampleName_L001_R1_001.fastq.gz and SampleName_L001_R2_001.fastq.gz


addpath('/RG/compbio/groupData/WIS_data/fenoam_ph2users/PhD/BACTERIA/6RegionsAlgo/Experiment/Reich/mFiles/Exp')
clear

% create cover_dir of name XX and under this dir create a directory called data_XX 
ExpName = 'mock_Experiment';
primer_set_file = '/home/shental/6Reg/Experiment/CoSMIC/qiagen_primers'; % this is a csv file (make sure the file name DOES NOT include .csv)
new_db_dir_name = '/home/shental/6Reg/Experiment/CoSMIC/dB/augmented_dB';
db_name = 'database_augmented_mock';
database_len = 200;
REGIONS = 1:6;
kmer_len = 135;



wrapper_SMURF('/RG/compbio/groupData/WIS_data/fenoam_ph2users/PhD/BACTERIA/6RegionsAlgo/Experiment/CoSMIC/run_file')


% command
% /home/shental/6Reg/Experiment/CoSMIC/SMURF/wrapper_SMURF/for_redistribution_files_only/run_wrapper_SMURF.sh /opt/apps/matlab/Runtime/v97/ /RG/compbio/groupData/WIS_data/fenoam_ph2users/PhD/BACTERIA/6RegionsAlgo/Experiment/CoSMIC/run_file

