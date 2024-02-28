#!/usr/bin/python

# stand alone script for checking scanner information (specific to University of Michigan scanner IDs)

from os.path import join as pathjoin
from os.path import sep
from glob import glob
from os.path import exists
import json

logfilename='checkscanner_log_.txt' #name logfile here
emailsender='ncwaller@med.umich.edu'
emailrecipient='ncwaller@med.umich.edu'

##### DIRECTORIES BELOW #####
script_dir = pathjoin(sep) #input path seperated by commas
log_dir = pathjoin(script_dir, 'logs')
bids_dir = pathjoin(sep) #input path seperated by commas

# create a log file with this iteration of script
try:
	logfile = open(pathjoin(log_dir, logfilename),'x')
	logfile.close()
except:
	print(logfilename+' exists!! quitting!!')
	quit()

# grab list of all subjects
subjects_list = glob(pathjoin(bids_dir, 'sub-mic*'))
subjects_list.sort()

for subject_dir in subjects_list:
	subject_name = subject_dir.split('/')[-1] #get subj name
	if exists(pathjoin(subject_dir, 'fmap')):
		json_list = glob(pathjoin(subject_dir, 'fmap', '*.json')) #if fieldmaps exist, grab the .json sidecars
		if len(json_list) == 0:
			logfile = open(pathjoin(log_dir,logfilename),'a')
			logfile.write(subject_name+': fmap folder empty... check DICOM header manually'+"\n") #if no .jsons
			logfile.close()
			print('scanner NOT identified for '+subject_name+'...check log file')
			continue
		else:
			json_file = json_list[1]
			f = open(json_file)
			data = json.load(f)
			station_name = data["StationName"]
			model_name = data["ManufacturersModelName"] #grab model class
			if (station_name == "GEHCGEHC" and model_name == "SIGNA UHP"): #specific scanner model
				scanner_name = "Inside Post-Upgrade"
			elif (station_name == "GEHCGEHC" and model_name == "DISCOVERY MR750"):
				scanner_name = "Inside Pre-Upgrade"
			elif (station_name == "MR01MR01" and model_name == "DISCOVERY MR750"):
				scanner_name = "Outside"
			else:
				scanner_name = "Unknown: Check"
			logfile = open(pathjoin(log_dir,logfilename),'a')
			logfile.write(subject_name+': Station - '+station_name+', Model - '+model_name+', Scanner - '+scanner_name+"\n")
			logfile.close()
			print('scanner identified for '+subject_name+'...check log file')
	elif not exists(pathjoin(subject_dir, 'fmap')):
		logfile = open(pathjoin(log_dir,logfilename),'a')
		logfile.write(subject_name+': fmap folder not found... check DICOM header manually'+"\n")
		logfile.close()
		print('scanner NOT identified for '+subject_name+'...check log file')
		
