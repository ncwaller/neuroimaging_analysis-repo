#!/usr/bin/python

# Generates two .nii files from RAW DICOMS per subject run, with .json sidecars (ex. a _4.nii and _4.json set, and a _1004.nii and _1004.json set, for cuffrun01)

from os import rename
from os.path import join as pathjoin
from os.path import sep
from glob import glob
from os import chdir as cd
from os.path import exists
import subprocess
import datetime
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders as Encoders


##### IMPORTANT ####
# Load dcm2niix_dev module as needed... as of Jan. 2023, no need to load in the dcm2niix_dev module anymore(auto-loaded)

dateandtime=str(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))

##### INITIALIZE BELOW #####
study_name='study_name '#enter study name here
logfilename='beforefmriprep_step00_rename_visits_prepare_fmaps_log_'+dateandtime+'.txt' #name logfile here 
emailsender='ncwaller@med.umich.edu' #change email address to send completion notice
emailrecipient='ncwaller@med.umich.edu' #change email address to recieve completion notice

##### DIRECTORIES BELOW #####
script_dir = pathjoin(sep) #change to where script is located
log_dir = pathjoin(script_dir, 'logs') #change to where log will be output
data_dir = pathjoin(sep) #change to where raw data is located

# create a log file with this iteration of script
try:
	logfile = open(pathjoin(log_dir,logfilename),'x')
	logfile.close()
except:
	print(logfilename+' exists!! quitting!!')
	quit()

# grab list of all subjects to rename
renamesubjects_list = glob(pathjoin(data_dir, 'mic*')) #change 'mic*' to grab prefix of current study
renamesubjects_list.sort()

# rename subjects
for subj in renamesubjects_list:
	if subj.split('/')[-1].split('_')[-1] == '1':
		new_subj = subj.split('/')[-1].replace('_1', 'pre')
		rename(subj, pathjoin(data_dir, new_subj))
	elif subj.split('/')[-1].split('_')[-1] == '2':
		new_subj = subj.split('/')[-1].replace('_2', 'post6mos')
		rename(subj, pathjoin(data_dir, new_subj))
	elif subj.split('/')[-1].split('_')[-1] == '3':
		new_subj = subj.split('/')[-1].replace('_3', 'post3mos')
		rename(subj, pathjoin(data_dir, new_subj))

# grab list of all subjects again for fieldmap prep
#allsubjects_list = glob(pathjoin(data_dir, 'mic*')) # change 'mic*' to grab prefix of current study
#allsubjects_list.sort()

# if you want to read a specific txt list for the subject list, uncomment this code block and comment out the previous
cd(script_dir)
with open ("subject_list") as f: #change name of list to txt file of interest
	allsubjects_list = [line.rstrip('\n') for line in f]
print(allsubjects_list)

# list of fmap types
fmap_types=['FM_cuff', 'FM_restpost', 'FM_restpre', 'FM_thumb', 'FM_visual'] #change for name of current fmaps

# unpack fmaps
cd(data_dir)
for subject_dir in allsubjects_list:
	for fmap_type in fmap_types:
		if exists(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type)): # if fmap of type exists
			if not exists(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom')): # within fmap folder, if extracted dicom folder does not exist
				print('dicom.tgz must be unpacked... beginning extraction...')
				cd(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type)) 
				subprocess.call(['tar', 'zxf', 'dicom.tgz']) # extract dicom.tgz
				cd(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom'))
				print('dicom.tgz unpacked... beginning to run dcm2niix_dev...')
				subprocess.call(['INSERT PATH TO DCM2NIIX_DEV MODULE', pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom')]) # run dcm2nixx_dev on extracted dicom folder
				print('dcm2niix_dev run')
			elif exists(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom')): # within fmap folder, if extracted dicom folder does exist
				print('dicom.tgz already unpacked... checking for dcm2niix_dev nii file')
				cd(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom'))
				if len(glob(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom', 'dicom_'+study_name+'*.nii')))!=0: # within extracted dicom folder, if dcm2niix_dev has already been run
					print('compiled .nii fmap file already exists ... not running dcm2niix_dev')
				elif len(glob(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom', 'dicom_'+study_name+'*.nii')))==0: # within extracted dicom folder, if dcm2niix_dev has not already been run
					print('compiled .nii fmap file does not already exist ... beginning to run dcm2niix')
					subprocess.call(['INSERT PATH TO DCM2NIIX_DEV MODULE', pathjoin(data_dir, subject_dir, 'func', 'fieldmaps', fmap_type, 'dicom')]) # run dcm2niix_dev
					print('dcm2niix_dev run')
				
	if not exists(pathjoin(data_dir, subject_dir, 'func', 'fieldmaps')): # if fmap directory does not exist
		logfile = open(pathjoin(log_dir,logfilename),'a')
		logfile.write('fieldmaps not available for '+subject_dir+'...check' + "\n")
		logfile.close()
		print('fieldmaps not available for '+subject_dir+'...check')

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
