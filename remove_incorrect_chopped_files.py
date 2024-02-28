#!/usr/bin/python

# script to remove files that have been uncorrectly chopped (specific use case, but I've been consistently suprised by how much I use it)

from os.path import join as pathjoin
from os.path import sep
from glob import glob
from os import chdir as cd
import datetime
import os

dateandtime=str(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))

##### INITIALIZE BELOW #####
study_name='study_name' #enter study name here 
logfilename='beforefmriprep_step01_BIDSformat_log_'+dateandtime+'.txt' #name logfile here

##### DIRECTORIES BELOW #####
script_dir = pathjoin(sep) #change to script parent dir 
log_dir = pathjoin(script_dir, 'logs')
data_dir = pathjoin(sep) #change to raw data dir
bids_dir = pathjoin(sep) #change to output (BIDS) dir
complete_dir = pathjoin(sep) #change to fMRIprep complete dir

# create a log file with this iteration of script
try:
	logfile = open(pathjoin(log_dir,logfilename),'x')
	logfile.close()
except:
	print(logfilename+' exists!! quitting!!')
	quit()

# grab list of all subjects
#allsubjects_list = glob(pathjoin(data_dir, 'mic05016pre*')) #need to change 'mic*' to grab prefix of current study
#allsubjects_list.sort()
#allsubjects = []
#for item in allsubjects_list:
#	allsubjects.append(item.split('/')[-1])

# if you want to read a specific txt list for the subject list, uncomment this code block and comment out the previous
cd(script_dir)
with open ("subject_list") as f: #change name of list to txt file of interest
	allsubjects_list = [line.rstrip('\n') for line in f]
print(allsubjects_list)

# grab list of already processed subjects 
done_list = glob(pathjoin(complete_dir, 'sub-mic*')) #need to change 'sub-mic*' to grab prefix of current study
done_list = [x for x in done_list if not x.endswith('.html')]
done_list.sort()
donesubjects = []
for item in done_list:
	donesubjects.append(item.split('/')[-1].split('-')[-1])
# now, get list of subjects not yet processed
subjectstouse = [x for x in allsubjects_list if x not in donesubjects]
subjects_list=[]
for subject in subjectstouse:
	subjects_list.append(pathjoin(data_dir, subject))
if len(subjects_list) == 0:
	print('No new subjects to copy into BIDS format...')
	quit()


if copyfuncBIDS == 1:
	for subject_dir in subjects_list:
		func_files_run=glob(pathjoin(subject_dir, 'func', '*', 'run_*', 'dicom', 'dicom_*chop12.nii.gz'))
		func_files_run.sort()
		for func_file_run in func_files_run:
			os.remove(func_file_run)

