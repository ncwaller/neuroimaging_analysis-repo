#!/usr/bin/python

# calculate max framewise displacement data from fMRIprep output, as well as other useful metrics of motion. excessive motion can inform subject exclusion

from os.path import join as pathjoin
from os.path import sep
from os import chdir as cd
from glob import glob
import pandas as pd
import numpy as np
import math
from scipy import signal
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = ['Arial']
import datetime
datetoday=datetime.datetime.now().strftime("%Y%m%d")

script_dir=pathjoin(sep) #insert script dir

main_df=pd.DataFrame()

data_dir = pathjoin(sep) #insert path to fMRIprep output
cd(data_dir)

subject_list = glob(pathjoin(data_dir, 'sub-*'))
subject_list = [x for x in subject_list if not x.endswith('.html')]
subject_list.sort()

for subject in subject_list:
	confound_files=glob(pathjoin(subject, 'func', '*cuffrun01_desc-confounds_timeseries.tsv')) #change based on specific task
	confound_files.sort()
	for confound_file in confound_files:
		name=(confound_file.split("/")[-1]).split('_')
		df=pd.read_csv(confound_file, sep='\t', header=0)
		# translation parameters
		X=signal.detrend(df['trans_x']); dX=np.diff(X); maxdX=abs(dX).max()
		Y=signal.detrend(df['trans_y']); dY=np.diff(Y); maxdY=abs(dY).max()
		Z=signal.detrend(df['trans_z']); dZ=np.diff(Z); maxdZ=abs(dZ).max()
		# Rotation parameters are in mm, as radians is multiplied by head radius
		# see Power et al. 2014 for reference
		# looking at J. Power's code, he used: deg=deg*(2*radius*pi/360), if it is in degrees
		# I believe fmriprep mcpar output is in radians, so we can just do radians*radius
		RotX_mm=(df['rot_x']*50); RotX_mm=signal.detrend(RotX_mm); dRotX_mm=np.diff(RotX_mm); maxdRotX_mm=abs(dRotX_mm).max()
		RotY_mm=(df['rot_y']*50); RotY_mm=signal.detrend(RotY_mm); dRotY_mm=np.diff(RotY_mm); maxdRotY_mm=abs(dRotY_mm).max()
		RotZ_mm=(df['rot_z']*50); RotZ_mm=signal.detrend(RotZ_mm); dRotZ_mm=np.diff(RotZ_mm); maxdRotZ_mm=abs(dRotZ_mm).max()
		# Rotation parameters kept in Radians		
		RotX=signal.detrend(df['rot_x']); dRotX=np.diff(RotX)
		RotY=signal.detrend(df['rot_y']); dRotY=np.diff(RotY)
		RotZ=signal.detrend(df['rot_z']); dRotZ=np.diff(RotZ)
		# Root Mean Square calculation based on - Van Dijk et al 2012 neuroimage
		# RMS Displacement		
		Disp_VanDijk = np.sqrt( dX**2 + dY**2 + dZ**2)
		# Euler Angle Rotation 
		Rot_VanDijk = np.arccos((np.cos(dRotX)*np.cos(dRotY) + np.cos(dRotX)*np.cos(dRotZ) + np.cos(dRotY)*np.cos(dRotZ) \
		+ np.sin(dRotX)*np.sin(dRotY)*np.sin(dRotZ) -1)/2)
		Rotmm_VanDijk = Rot_VanDijk * 50 #now convert to millimeters based on Power et al multiplication of head radius
		# max and mean of measures
		maxDisp_VanDijk = Disp_VanDijk.max()
		maxRot_VanDijk = Rotmm_VanDijk.max()
		meanDisp_VanDijk = Disp_VanDijk.mean()
		meanRot_VanDijk = Rotmm_VanDijk.mean()
		# Power 2012 Neuroimage
		Disp_JPower = abs(dX)+abs(dY)+abs(dZ)
		Rotmm_JPower = abs(dRotX_mm)+abs(dRotY_mm)+abs(dRotZ_mm)
		# Framewise Displacement Calculations
		FD_JPower = Disp_JPower + Rotmm_JPower 
		maxFD_JPower = FD_JPower.max()	# [power 2012 neuroimage]
		meanFD_JPower = FD_JPower.mean()
		# Framewise Displacement from FMRIPREP
		FD_fmriprep = df['framewise_displacement']
		maxFD_fmriprep = FD_fmriprep.max()
		meanFD_fmriprep = FD_fmriprep.mean()
		# DVARS from FMRIPREP - Tom Nichol's "standard" version
		DVARS_fmriprep = df['std_dvars']
		maxDVARS_fmriprep = DVARS_fmriprep.max()
		meanDVARS_fmriprep = DVARS_fmriprep.mean()
		# gather everything in a dataframe called main_df	
		main_df = main_df.append({'Sub': name[0].split("-")[1], \
		'Max RMS Displacement VanDijk': maxDisp_VanDijk, \
		'Max RMS Rotation VanDijk': maxRot_VanDijk, \
		'Max Framewise Displacement JPower': maxFD_JPower, \
		'Max Framewise Displacement Fmriprep': maxFD_fmriprep, \
		'Max Standardized DVARS TNichols': maxDVARS_fmriprep, \
		'Mean RMS Displacement VanDijk': meanDisp_VanDijk, \
		'Mean RMS Rotation VanDijk': meanRot_VanDijk, \
		'Mean Framewise Displacement JPower': meanFD_JPower, \
		'Mean Framewise Displacement Fmriprep': meanFD_fmriprep,
		'Mean Standardized DVARS TNichols': meanDVARS_fmriprep}, \
		ignore_index=True)
		#clear variables
		del(name, df, X, Y, Z, dX, dY, dZ, maxdX, maxdY, maxdZ, RotX, RotY, RotZ, dRotX, dRotY, dRotZ, \
		RotX_mm, RotY_mm, RotZ_mm, dRotX_mm, dRotY_mm, dRotZ_mm, maxdRotX_mm, maxdRotY_mm, maxdRotZ_mm, \
		Disp_VanDijk, Rot_VanDijk, Rotmm_VanDijk, maxDisp_VanDijk, maxRot_VanDijk, meanDisp_VanDijk, meanRot_VanDijk, \
		Disp_JPower, Rotmm_JPower, FD_JPower, maxFD_JPower, meanFD_JPower, FD_fmriprep, maxFD_fmriprep, meanFD_fmriprep, \
		maxDVARS_fmriprep, meanDVARS_fmriprep)

######
cd(script_dir)

variables = ['Max RMS Displacement VanDijk', \
'Max RMS Rotation VanDijk', \
'Max Framewise Displacement JPower', \
'Max Framewise Displacement Fmriprep', \
'Max Standardized DVARS TNichols']

for variable in variables:
	value = math.ceil(main_df[variable].max())
	if value == 1:
		interval=0.05 
	elif value > 1 and value <= 8:
		interval=0.5
	elif value > 8 and value <=20:
		interval=1.0
	elif value > 20:
		interval=5.0

	cutoffs = np.arange(interval, value+interval, interval)
	n_subjects_left = []
	for cutoff in cutoffs:
		tmp = main_df.loc[main_df[variable] <= cutoff].shape[0]
		n_subjects_left = np.append(n_subjects_left, tmp)
		del(tmp)
	
	fig, ax = plt.subplots(figsize=(7,7))
	ax.plot(cutoffs, n_subjects_left, color='black', linestyle='-', marker='o', \
	markerfacecolor='black', markersize=6)
	ax.set_title(variable, fontsize=18)
	ax.set_xlabel("Cutoff", fontsize=18)
	ax.set_ylabel("Number of Scan Runs Retained", fontsize=18)
	ax.tick_params(axis = 'both', labelsize=16)
	plt.xticks(cutoffs)
	fig.savefig(variable.replace(' ', '')+'_'+datetoday+'cuff'+'.png')
	plt.close('all')
	

#######

highFDandDVARS=main_df.loc[(main_df['Max Standardized DVARS TNichols']>5) | (main_df['Max Framewise Displacement Fmriprep']>5)]
usableFDandDVARS=main_df.loc[(main_df['Max Standardized DVARS TNichols']<=5) & (main_df['Max Framewise Displacement Fmriprep']<=5)]
highFDandDVARS[['Sub']].to_csv('highFDandDVARS_cuff_'+datetoday+'.csv', index=False) #change output names to specify task
usableFDandDVARS[['Sub']].to_csv('usableFDandDVARS_cuff_'+datetoday+'.csv', index=False) #change output names to specify task

highFD=main_df.loc[(main_df['Max Framewise Displacement Fmriprep']>5)]
usableFD=main_df.loc[(main_df['Max Framewise Displacement Fmriprep']<=5)]
highFD[['Sub']].to_csv('highFD_cuff_'+datetoday+'.csv', index=False) #change output names to specify task
usableFD[['Sub']].to_csv('usableFD_cuff_'+datetoday+'.csv', index=False) #change output names to specify task

