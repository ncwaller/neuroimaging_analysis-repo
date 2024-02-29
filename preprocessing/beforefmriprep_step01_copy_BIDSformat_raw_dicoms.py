#!/usr/bin/python

# Created by Ishtiaq Mawla and Eric Ichesco on Sept 16, 2019
# Chronic Pain and Fatigue Research Center, University of Michigan
# Altered by Noah Waller on April 28, 2022

from os.path import join as pathjoin
from os.path import sep
from os.path import dirname
from glob import glob
from os import chdir as cd
from os import makedirs as mkdir
from os import remove as rm
from os.path import exists
from os.path import isfile
from ntpath import basename
from nipype.interfaces.fsl import Merge
import subprocess
from subprocess import PIPE, run
import numpy as np
import datetime
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders as Encoders
import tarfile
import os
import json

##### IMPORTANT ####
# No need to load in the dcm2niix_dev module anymore
# This script creates _chop.nii.gz files when volumes are chopped to fit the ideal run length. This is a recent change, so re-running this on older CORT subjects (those old ones that still have raw dicoms) will just redo everything and take a while to generate the new _chop.nii.gz files, as opposed to the previous script iteration that generated .nii.gz files without a chop suffix (even when chopped). So, for time's sake, use subject lists if I want to run newer batches

dateandtime=str(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
##### INITIALIZE BELOW #####
study_name='M' #enter study name here #this is a pain because it's often different between subjects (ex. MiCAPP, MICAPP, MiCaPP, micapp)... so I think I'll just leave it as "M"
copyanatBIDS = 1 #use 1 to copy anat files to BIDS format
correctfuncvols = 1 #use to check func files for correct vol # and edit if incorrect, including chopping beginning volumes if necessary
copyfuncBIDS = 1 #use 1 to copy func files to BIDS format 
copyfmapBIDS = 1 #use 1 to copy fmap files to BIDS format 
func_types = ['cuff', 'restpost', 'restpre', 'thumb', 'visual'] #types of runs
func_types_vols = {"cuff": 450,"restpost": 450,"restpre": 450,"thumb": 478,"visual": 251} #input number of expected volumes per run
func_vols_cut = 12 #input number of leading volumes to remove, if any. if none, set to 0
logfilename='beforefmriprep_step01_BIDSformat_log_'+dateandtime+'.txt' #name logfile here
emailsender='ncwaller@med.umich.edu' #change email address to send completion notice
emailrecipient='ncwaller@med.umich.edu' #change email address to send completion notice

##### DIRECTORIES BELOW #####
script_dir = pathjoin(sep, 'PROJECTS', 'REHARRIS', 'noah', 'analysis_CORTmicapp', 'analysis_VIS-CORT_paper', 'scripts') #change to where script is located
log_dir = pathjoin(script_dir, 'logs') #change to where log will be output
data_dir = pathjoin(sep, 'PROJECTS', 'micapp', 'raw') #change to where raw data is located
bids_dir = pathjoin(sep, 'PROJECTS', 'micapp', 'micapp_BIDS_nov2023_rawonly') #change to where BIDSified data will be located
complete_dir = pathjoin(sep, 'PROJECTS', 'micapp', 'fmriprep_complete_nov2023_rawonly') #change to where post-fMRIprep preprocessed data is located

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
with open ("ALL_raw_cort_subjects") as f: #change name of list to txt file of interest
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

### ANAT ###
if copyanatBIDS == 1:
	for subject_dir in subjects_list:
		cd(subject_dir)
		subject_name_bids='sub-'+subject_dir.split('/')[-1].replace("-","").replace("_","") # define subject name
		cd(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl'))
		if exists(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom')): # within anat folder, if extracted dicom folder already exists
			print('dicom.tgz has already been extracted for', subject_name_bids, 'anatomical')
			anat_dir=pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom')
			if len(glob(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom', 'dicom_'+study_name+'*.nii')))!=0: # within extracted dicom folder, if dcm2niix_dev has already been run #add comment to top about adapting names for study specifics
				print('compiled .nii file already exists for', subject_name_bids, 'anatomical... not running dcm2niix_dev')
			elif len(glob(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom', 'dicom_'+study_name+'*.nii')))==0: # within extracted dicom folder, if dcm2niix_dev has not already been run
				print('compiled .nii file does not already exist for', subject_name_bids, 'anatomical... beginning to run dcm2niix')
				subprocess.call(['/app/apps/rhel8/dcm2niix/1.0.20220720/bin/dcm2niix_dev', anat_dir]) # run dcm2niix_dev
				print('dcm2niix_dev complete for', subject_name_bids, 'anatomical')	
		elif not exists(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom')): # within anat folder, if extracted dicom folder does not exist
			print('must extract dicom.tgz for', subject_name_bids, 'anatomical... beginning extraction...')
			cd(pathjoin(subject_dir, 'anatomy', 't1spgr_208sl'))
			tar = tarfile.open('dicom.tgz', "r:gz") # extract dicom.tgz
			tar.extractall()
			tar.close()
			print('extraction complete for', subject_name_bids, 'anatomical... beginning to run dcm2niix_dev...')	
			anat_dir=pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom')
			subprocess.call(['/app/apps/rhel8/dcm2niix/1.0.20220720/bin/dcm2niix_dev', anat_dir]) # run dcm2niix_dev
			print('dcm2niix_dev complete for', subject_name_bids, 'anatomical')

		# define anat bids file format and directory
		anat_dir=pathjoin(subject_dir, 'anatomy', 't1spgr_208sl', 'dicom')
		dir_list=os.listdir(anat_dir)
		for file in dir_list:
			if file.endswith(".nii") & file.startswith("dicom_"+study_name):
				nii_file=file
		anat_file_bids=pathjoin(bids_dir, subject_name_bids, 'anat', subject_name_bids+'_T1w.nii')
		if not exists(pathjoin(bids_dir, subject_name_bids, 'anat')): # if bids dir for anat doesn't exist
			mkdir(pathjoin(bids_dir, subject_name_bids, 'anat'))
		if exists(pathjoin(anat_dir, nii_file)): # if dcm2niix_dev anat file exists in raw file dir
			if exists(anat_file_bids+'.gz'): # if dcm2niix_dev anat file exists in bids file dir
				continue		
			else: # if dcm2niix_dev anat file does not exist in bids file dir
				subprocess.call(['cp', pathjoin(anat_dir, nii_file), anat_file_bids]) 
				subprocess.call(['gzip', anat_file_bids])
		elif not exists(pathjoin(anat_dir, nii_file)): # if anat does not exist in raw file dir
			logfile = open(pathjoin(log_dir,logfilename),'a')
			logfile.write(subject_name_bids+" anatomy directory doesn't have T1...please check" + "\n")
			logfile.close()
			print(subject_name_bids,"anatomy directory doesn't have T1...please check")
	

### FUNC ###
if copyfuncBIDS == 1:
	for subject_dir in subjects_list:
		cd(subject_dir)
		subject_name_bids='sub-'+subject_dir.split('/')[-1].replace("-","").replace("_","") # define subject name
		cd(pathjoin(subject_dir, 'func'))
		for func_type in func_types:
			if not exists(pathjoin(subject_dir, 'func', func_type)): # if func run of type does not exist
				print(func_type, 'run directory does not exist for', subject_name_bids)
				continue
			elif exists(pathjoin(subject_dir, 'func', func_type)): # if func run of type exists
				print(func_type, 'run directory does exist for', subject_name_bids)
				all_runs = glob(pathjoin(subject_dir, 'func', func_type, 'run_*'))
				for run in all_runs:
					if exists(pathjoin(subject_dir, 'func', func_type, run, 'dicom')): # within func run folder, if extracted dicom folder does exist
						print('dicom.tgz has already been extracted for', subject_name_bids, func_type)
						task_dir=pathjoin(subject_dir, 'func', func_type, run, 'dicom')
						if len(glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*.nii')))!=0: # within extracted dicom folder, if dcm2niix_dev has already been run
							print('compiled .nii file already exists for', subject_name_bids, func_type, '... not running dcm2niix_dev')
					### VOL CHOP AND CORRECT
							if correctfuncvols == 1: #if volume chopping is needed, check the .nii file and run fslroi
								print('need to chop volumes at beginning of run for', subject_name_bids, func_type)
		
								if len(glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*rrc-450-cut.nii.gz')))!=0: # within func/func_run/dicom folder, if dicom_* volumes have already been chopped 
									print('volumes already chopped for', subject_name_bids, func_type)
								else: 
									func_crop_file_list = glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*.nii')) #important that this list is one item... so important there are no file copy duplicates of .nii files in the raw dicom directory post-dcm2niix
									func_crop_file = ' '.join(func_crop_file_list) #converts single item list to str for fslroi to act on
									cd(pathjoin(subject_dir, 'func', func_type, run, 'dicom'))
									total_vol = func_types_vols[func_type] 
									total_vol_str = str(total_vol) #converts total volume to string
									func_vols_cut_str = str(func_vols_cut)
									func_crop_file_outname_base = func_crop_file.split('/')[-1].replace('.nii','')
									func_crop_file_outname = func_crop_file_outname_base+'_rrc-450-cut.nii' #defines output chopped file name (might not keep this)
									
									subprocess.call(['fslroi', func_crop_file, func_crop_file_outname, func_vols_cut_str, total_vol_str]) #just needs all input to be strings, as done above
									print('volumes chopped and corrected for', subject_name_bids, func_type)

						elif len(glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*.nii')))==0: # within extracted dicom folder, if dcm2niix_dev has not been run
							print('compiled .nii file does not already exist for', subject_name_bids, func_type, '... beginning to run dcm2niix')
							subprocess.call(['/app/apps/rhel8/dcm2niix/1.0.20220720/bin/dcm2niix_dev', task_dir]) # run dcm2niix_dev
							print('dcm2niix_dev complete for', subject_name_bids, func_type)

					### VOL CHOP AND CORRECT
							if correctfuncvols == 1: #if volume chopping is needed, check the .nii file and run fslroi
								print('need to chop volumes at beginning of run for', subject_name_bids, func_type)
								
								if len(glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*rrc-450-cut.nii.gz')))!=0: # within func/func_run/dicom folder, if dicom_* volumes have already been chopped 
									print('volumes already chopped for', subject_name_bids, func_type)
								else: 
									func_crop_file_list = glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*.nii')) #important that this list is one item... so important there are no file copy duplicates of .nii files in the raw dicom directory post-dcm2niix
									func_crop_file = ' '.join(func_crop_file_list) #converts single item list to str for fslroi to act on
									cd(pathjoin(subject_dir, 'func', func_type, run, 'dicom'))
									total_vol = func_types_vols[func_type] 
									total_vol_str = str(total_vol) #converts total volume to string
									func_vols_cut_str = str(func_vols_cut)
									func_crop_file_outname_base = func_crop_file.split('/')[-1].replace('.nii','')
									func_crop_file_outname = func_crop_file_outname_base+'_rrc-450-cut.nii' #defines output chopped file name (might not keep this)
									
									subprocess.call(['fslroi', func_crop_file, func_crop_file_outname, func_vols_cut_str, total_vol_str]) #just needs all input to be strings, as done above
									print('volumes chopped and corrected for', subject_name_bids, func_type)

					elif not exists(pathjoin(subject_dir, 'func', func_type, run, 'dicom')): #within func run folder, if extracted dicom does not exist
						print('must extract dicom.tgz for', subject_name_bids, func_type, '... beginning extraction...')
						cd(pathjoin(subject_dir, 'func', func_type, run))
						tar = tarfile.open('dicom.tgz', "r:gz") # extract dicom.tgz
						tar.extractall()
						tar.close()
						print('extraction complete for', subject_name_bids, func_type, '... beginning to run dcm2niix_dev...')	
						task_dir=pathjoin(subject_dir, 'func', func_type, run, 'dicom')
						subprocess.call(['/app/apps/rhel8/dcm2niix/1.0.20220720/bin/dcm2niix_dev', task_dir]) # run dcm2niix_dev
						print('dcm2niix_dev complete for', subject_name_bids, func_type)	
		
					### VOL CHOP AND CORRECT
						if correctfuncvols == 1: #if volume chopping is needed, check the .nii file and run fslroi
							print('need to chop volumes at beginning of run for', subject_name_bids, func_type)
							#if func_type == 'cuff':
							if len(glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*rrc-450-cut.nii.gz')))!=0: # within func/func_run/dicom folder, if dicom_* volumes have already been chopped 
								print('volumes already chopped for', subject_name_bids, func_type)
							else: 
								func_crop_file_list = glob(pathjoin(subject_dir, 'func', func_type, run, 'dicom', 'dicom_'+study_name+'*.nii')) #important that this list is one item... so important there are no file copy duplicates of .nii files in the raw dicom directory post-dcm2niix
								func_crop_file = ' '.join(func_crop_file_list) #converts single item list to str for fslroi to act on
								cd(pathjoin(subject_dir, 'func', func_type, run, 'dicom'))
								total_vol = func_types_vols[func_type] 
								total_vol_str = str(total_vol) #converts total volume to string
								func_vols_cut_str = str(func_vols_cut)
								func_crop_file_outname_base = func_crop_file.split('/')[-1].replace('.nii','')
								func_crop_file_outname = func_crop_file_outname_base+'_rrc-450-cut.nii' #defines output chopped file name (might not keep this)
									
								subprocess.call(['fslroi', func_crop_file, func_crop_file_outname, func_vols_cut_str, total_vol_str]) #just needs all input to be strings, as done above
								print('volumes chopped and corrected for', subject_name_bids, func_type)
	
# get functional files
		func_files_run=glob(pathjoin(subject_dir, 'func', '*', 'run_*', 'dicom', 'dicom_*rrc-450-cut.nii.gz')) # get raw .nii run files (these are the _chop.nii.gz files generated through the raw DICOMS)
		func_files_json=glob(pathjoin(subject_dir, 'func', '*', 'run_*', 'dicom', 'dicom_*.json')) # get raw .json files
		func_files_run.sort()
		func_files_json.sort()
		if not exists(pathjoin(bids_dir, subject_name_bids, 'func')): # if bids dir for func doesn't exist
			mkdir(pathjoin(bids_dir, subject_name_bids, 'func'))
	
		# iterate through func run .nii files, bidsify, and copy
		for func_file_run in func_files_run:
			task_name_bids='task-'+''.join(func_file_run.split('/')[-4:-2]).replace("_","")
			func_file_bids=pathjoin(bids_dir, subject_name_bids, 'func', subject_name_bids+'_'+task_name_bids+'_bold.nii.gz')
			if exists(func_file_bids):
				continue
			else:
				# Copy the .nii file from raw directory to bids directory
				subprocess.call(['cp', func_file_run, func_file_bids])
				with open(pathjoin(bids_dir, subject_name_bids, 'func', 'notes.txt'), 'a') as notes_file:
					notes_file.write("nii copied for "+subject_name_bids+' '+task_name_bids+' '+dateandtime+'\n')
				
		#next iterate through .json files, bidsify, copy, and edit
		for func_file_json in func_files_json:
			task_name_bids='task-'+''.join(func_file_json.split('/')[-4:-2]).replace("_","")
			func_file_bids=pathjoin(bids_dir, subject_name_bids, 'func', subject_name_bids+'_'+task_name_bids+'_bold.json')
			if exists(func_file_bids): 
				continue
			else:
				# Step 1: Copy the .json file from raw directory to bids directory
				subprocess.call(['cp', func_file_json, func_file_bids])
				with open(pathjoin(bids_dir, subject_name_bids, 'func', 'notes.txt'), 'a') as notes_file:
					notes_file.write("json copied for "+subject_name_bids+' '+task_name_bids+' '+dateandtime+'\n')
				
				# Step 2: add necessary TaskName field to .json file
				cd(pathjoin(bids_dir, subject_name_bids, 'func'))
				task=func_file_bids.split('task-')[-1].split('_')[0]
				file_json = open(func_file_bids, "r")
				func_json = json.load(file_json)
				file_json.close()
				func_json["TaskName"]= task
				file_json = open(func_file_bids, "w")
				json.dump(func_json, file_json)
				file_json.close()


### FMAPS ###
# copy field maps and .json files
if copyfmapBIDS == 1:
	for subject_dir in subjects_list:
		cd(subject_dir)
		subject_name_bids='sub-'+subject_dir.split('/')[-1].replace("-","").replace("_","") # define subject name
		if not exists(pathjoin(bids_dir, subject_name_bids, 'fmap')): # if bids dir for fmap does not exist
			mkdir(pathjoin(bids_dir, subject_name_bids, 'fmap'))
		if len(glob(pathjoin(bids_dir, subject_name_bids, 'fmap', '*epi.nii.gz')))==0: # if bids dir for fmap does exist and contains no runs
			copied_func_files=glob(pathjoin(bids_dir, subject_name_bids, 'func', 'sub-*bold.nii.gz'))
			copied_func_files.sort()
			for copied_func_file in copied_func_files:
				task=copied_func_file.split('run')[0].split('task-')[-1]
				fieldmaps=glob(pathjoin(subject_dir, 'func', 'fieldmaps', 'FM_'+task, 'dicom', 'dicom_'+study_name+'*.nii'))
				fieldmaps_json=glob(pathjoin(subject_dir, 'func', 'fieldmaps', 'FM_'+task, 'dicom', 'dicom_'+study_name+'*.json'))
				for fieldmapjsonindex, fieldmap_json in enumerate(fieldmaps_json):
					# count number of fmap .json files present in current bids dir
					current_num_of_fmaps_json=len(glob(pathjoin(bids_dir, subject_name_bids, 'fmap', '*.json')))
					# assigned epi .json for next fmap that will be copied over
					next_fmap_json_num=str(current_num_of_fmaps_json+1).zfill(2)
					# open and search .json file for the series number
					f = open(fieldmap_json)
					data = json.load(f)
					series_number = data["SeriesNumber"]
					# if series number is less than 1000...
					if (series_number < 1000):
						# find corresponding .nii file and assign to variable
						base = os.path.splitext(fieldmap_json)[0]
						fieldmap_nii = pathjoin(base + '.nii')
						# assign .json BIDS name as *dir-PA*
						fieldmap_json_bids=pathjoin(bids_dir, subject_name_bids, 'fmap', \
subject_name_bids+'_dir-PA'+'_run-'+next_fmap_json_num+'_epi.json')						
						# assign .nii BIDS name as *dir-PA*
						fieldmap_nii_bids=pathjoin(bids_dir, subject_name_bids, 'fmap', \
subject_name_bids+'_dir-PA'+'_run-'+next_fmap_json_num+'_epi.nii')
					# if series number is greater than 1000...
					elif (series_number > 1000):
						# find corresponding .nii file and assign to variable
						base = os.path.splitext(fieldmap_json)[0]
						fieldmap_nii = pathjoin(base + '.nii')
						# assign .json BIDS name/variable as *dir-AP*
						fieldmap_json_bids=pathjoin(bids_dir, subject_name_bids, 'fmap', \
subject_name_bids+'_dir-AP'+'_run-'+next_fmap_json_num+'_epi.json')
						# assign .nii BIDS name/variable as *dir-AP*
						fieldmap_nii_bids=pathjoin(bids_dir, subject_name_bids, 'fmap', \
subject_name_bids+'_dir-AP'+'_run-'+next_fmap_json_num+'_epi.nii')	
					f.close()
					# add necessary IntendedFor field to .json file
					f = open(fieldmap_json, "r")
					data = json.load(f)
					f.close()
					data["IntendedFor"]= "func/"+copied_func_file.split('/')[-1]
					f = open(fieldmap_json, "w")
					json.dump(data, f)
					f.close()
					# copy over the fmap .JSON file to the BIDS-ified name/dir
					subprocess.call(['cp', fieldmap_json, fieldmap_json_bids])
					# copy over the fmap .nii file to the BIDS-ified name/dir
					subprocess.call(['cp', fieldmap_nii, fieldmap_nii_bids])
					# gzip the fmap .nii file
					subprocess.call(['gzip', fieldmap_nii_bids])

# put a dataset_description.json file in the parent bids directory
if not exists(pathjoin(bids_dir, 'dataset_description.json')):
	with open(pathjoin(bids_dir, 'dataset_description.json'), 'w') as dataset_description:
		dataset_description.write('{\n')
		dataset_description.write('\t\"Name\":\"'+study_name+'\",\n')
		dataset_description.write('\t\"BIDSVersion\":\"1.1.0\"\n')
		dataset_description.write('}\n')

######################################################################################

# email contents of log file
msg = MIMEMultipart()
msg['From'] = emailsender #email messages with script output will be sent from this address
msg['To'] = emailrecipient #email messages with script output will be sent to this address
msg['Subject'] = study_name + ' '+ logfilename

part = MIMEBase('application', "octet-stream")
part.set_payload(open(pathjoin(log_dir,logfilename), "rb").read())
Encoders.encode_base64(part)

part.add_header('Content-Disposition', 'attachment; filename='+logfilename)

msg.attach(part)

server = smtplib.SMTP('localhost')
server.send_message(msg)
server.quit()
