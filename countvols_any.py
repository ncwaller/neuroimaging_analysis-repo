#!/usr/bin/python

# simply counts volumes for any specified functional run type and outputs to log file

from os.path import join as pathjoin
from os.path import sep
from glob import glob
from subprocess import PIPE, run
import datetime

dateandtime=str(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))

logfilename='afterfmriprep_step02_checkvols_log_'+dateandtime+'.txt' #name logfile here
emailsender='ncwaller@med.umich.edu'
emailrecipient='ncwaller@med.umich.edu'

##### DIRECTORIES BELOW #####
script_dir = pathjoin(sep) #change to script dir
log_dir = pathjoin(script_dir, 'logs')
data_dir = pathjoin(sep, '...', 'fmriprep_complete') #uncomment if looking at fMRIprep formatted .nii.gz files)
#data_dir = pathjoin(sep, '...', 'BIDS_complete') #uncomment if looking at BIDS formatted .nii.gz files)
#data_dir = pathjoin(sep, '...', 'raw') #uncomment out if looking at raw files (prun.nii or dicom*.nii)
subjectlist_dir = pathjoin(sep) #change to parent dir with subject list (.txt file)

# create a log file with this iteration of script
try:
	logfile = open(pathjoin(log_dir, logfilename),'x')
	logfile.close()
except:
	print(logfilename+' exists!! quitting!!')
	quit()

# grab list of all subjects
subjects_list = glob(pathjoin(data_dir, 'sub-mic*')) #edit as needed
subjects_list = [x for x in subjects_list if not x.endswith('.html')]
subjects_list.sort()

# if you want to read a specific txt list for the subject list, uncomment this code block and comment out the previous
#cd(subjectlist_dir)
#with open ("ALL_raw_subIDs") as f: #change name of list to txt file of interest (remember the different between sub-mic* and mic*
#	allsubjects_list = [line.rstrip('\n') for line in f]
#print(allsubjects_list)
#subjects_list=[]
#for subject in allsubjects_list:
#	subjects_list.append(pathjoin(data_dir, subject))

func_run_interest = 'visualrun01' #edit as needed

for subject_dir in subjects_list:
    
    #code blocks below can be uncommented/commented out as needed, depending on what type of run is being counted

	if len(glob(pathjoin(subject_dir, 'func', '*'+func_run_interest+'*desc-preproc_bold.nii.gz')))==0: #fMRIprep
		print('no '+func_run_interest+' file for subject: '+subject_dir) #bids
	func_run_check = glob(pathjoin(subject_dir, 'func', '*'+func_run_interest+'*desc-preproc_bold.nii.gz')) #fMRIprep

	#if len(glob(pathjoin(subject_dir, 'func', func_run_interest, 'run_01', 'prun_01.nii')))==0: #prun
	#	print('no '+func_run_interest+' file for subject: '+subject_dir) #prun
	#func_run_check = glob(pathjoin(subject_dir, 'func', func_run_interest, 'run_*', 'prun_01.nii')) #prun

	#if len(glob(pathjoin(subject_dir, 'func', '*'+func_run_interest+'*.nii.gz')))==0: #bids
	#	print('no '+func_run_interest+' file for subject: '+subject_dir) #bids
	#func_run_check = glob(pathjoin(subject_dir, 'func', '*'+func_run_interest+'*.nii.gz')) #bids

	#if len(glob(pathjoin(subject_dir, 'func', '*'+func_run_interest+'*.nii.gz')))==0: #raw
		#print('no '+func_run_interest+' file for subject: '+subject_dir) #raw
	#func_run_check = glob(pathjoin(subject_dir, 'func', 'cuff', 'run_*', 'dicom', 'dicom_*.nii')) #raw

#need to include func type loop nest
	for func_run in func_run_check:	
		#file_name = func_run.split('/')[-1]
		#func_type = file_name.split('_')[-2].replace('task-','')#.replace('run01','')
		#if func_type == func_interest:		
		results=run(['fslinfo', func_run, '-lnp'], stdout=PIPE, stderr=PIPE, universal_newlines=True)
		nvols=results.stdout.split('\n')[4]
		logfile = open(pathjoin(log_dir,logfilename),'a')
		logfile.write(func_run+' ::length:: '+nvols+"\n")
		logfile.close()
		#else:
		#	continue
		
