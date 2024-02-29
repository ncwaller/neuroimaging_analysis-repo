#!/usr/bin/python

# after fMRIprep, this script performs various post-processing features left out of fMRIprep and necessary for subsequent analysis

# before running this script, you have to execute the following commands
# module load AFNI

# careful with this script if TR is incorrect in the header
# you need to manually input TR if it is incorrect in the header
# see below in the 3dTproject section
# can check with fslinfo 

##########################################################################################################################

from os.path import join as pathjoin
from os.path import sep
from os.path import exists
from os import chdir as cd
from glob import glob
import pandas as pd
import numpy as np
from nipype.interfaces import fsl
from nipype.interfaces import afni

func_types = ['cuff', 'restpre', 'restpost', 'thumb', 'visual'] #types of runs

# change data_dir below to whatever the directory of the data is
data_dir = pathjoin(sep)
cd(data_dir)

# grab subjects
subjects_list = glob(pathjoin(data_dir, 'sub-mic*'))
subjects_list = [x for x in subjects_list if not x.endswith('.html')]
subjects_list.sort()
print(subjects_list)

for subject_dir in subjects_list:
	subj = subject_dir.split('/')[-1]
	for func_type in func_types:
		task = func_type
		if exists(pathjoin(subject_dir, 'func', subj+'_task-'+task+'run01'+'_desc-confounds_timeseries.tsv')): #find confounds file
			confound_file = glob(pathjoin(subject_dir, 'func', subj+'_task-'+task+'run01'+'_desc-confounds_timeseries.tsv'))[0]
			df=pd.read_csv(confound_file, sep='\t', header=0)
			func_dir=pathjoin(data_dir,subj,'func')
			cd(func_dir)
			if set(['a_comp_cor_00', 'a_comp_cor_01', 'a_comp_cor_02', 'a_comp_cor_03', 'a_comp_cor_04', 'a_comp_cor_05', 'trans_x', 'trans_y', 'trans_z', 'rot_x','rot_y', 'rot_z']).issubset(df.columns):
				#6 parameter regression + aCompCor
				aCompCor6par6=df[['a_comp_cor_00', 'a_comp_cor_01', 'a_comp_cor_02', 'a_comp_cor_03', 'a_comp_cor_04', 'a_comp_cor_05', 'trans_x', 'trans_y', 'trans_z', 'rot_x','rot_y', 'rot_z']]
				saveparfile=subj+'_task-'+task+'run01'+'_desc_confounds'+'_'+'aCompCor6par6.1D'
				if not exists(saveparfile):
					aCompCor6par6.to_csv(saveparfile, index=False, sep='\t', header=None)
				del(saveparfile)
			if set(['trans_x', 'trans_y', 'trans_z', 'rot_x','rot_y', 'rot_z']).issubset(df.columns):
				#6 parameter regression only
				motionpar6=df[['trans_x', 'trans_y', 'trans_z', 'rot_x','rot_y', 'rot_z']]
				saveparfile=subj+'_task-'+task+'run01'+'_desc_confounds'+'_'+'motionpar6.txt'
				if not exists(saveparfile):
					motionpar6.to_csv(saveparfile, index=False, sep='\t', header=None)
				del(saveparfile)
				#prepare for running 3dTproject
				design_file=pathjoin(data_dir,subj,'func',subj+'_task-'+task+'run01_'+'desc_confounds'+'_'+'aCompCor6par6.1D')
				design_file_name=(design_file.split("/")[-1]).split('_')[-1].split('.')[0]
				in_file=pathjoin(data_dir,subj,'func',subj+'_task-'+task+'run01_'+'space-MNI152NLin6Asym_res-2_desc-preproc_bold.nii.gz')
				#filename is designated in out_file as follows based on tproject.inputs.bandpass
				out_file=in_file.split(".nii.gz")[0] + '_' + 'tproj_hipass01_' + design_file_name + '_sm6mm' + '.nii.gz'
				if not exists(out_file):
					try:
						tproject=afni.TProject() #setting function
						tproject.inputs.in_file=in_file #setting input file
						tproject.inputs.bandpass=(0.01, 99999) #change out_file name if you change this #highpass filter
						#tproject.inputs.mask=mask_file #masking performed at bottom of script; vestigial code line
						tproject.inputs.ort=design_file #compcor + para
						tproject.inputs.polort=1 #drift correction
						tproject.inputs.blur=6 #smoothing kernel
						tproject.inputs.out_file=out_file #output file
						tproject.inputs.outputtype='NIFTI_GZ' #output type
						# remove comment from line below if TR is incorrect in the header file information
						# tproject.inputs.TR=2
						print('running 3dTproject '+ design_file_name + ' ' + in_file.split('/')[-1] + ' ...')
						tproject.run()
						print('===')
						print('   ')
					except: 
						print ('WARNING: 3dTproject for ' + design_file_name + ' ' + in_file.split('/')[-1] + ' DID NOT RUN!')
		elif not exists(pathjoin(subject_dir, 'func', subj+'_task-'+task+'run01'+'_desc-confounds_timeseries.tsv')):
			continue
	##########################################################################################################################
    
    # masking performed here

from os.path import join as pathjoin
from os.path import split as pathsplit
from os.path import exists
from os.path import sep
from os import chdir as cd
from glob import glob
from nipype.interfaces import fsl
from nipype.interfaces import afni

cd(data_dir)

subject_list = glob(pathjoin(data_dir, 'sub-mic*','func','*_space-MNI152NLin6Asym_res-2_desc-preproc_bold*_sm6mm.nii.gz'))
subject_list.sort()

mask_file= #insert path to mask

for subject in subject_list:
	cd(pathsplit(subject)[0])
	# skullstrip here
	if not exists(subject.split('.nii')[0]+'_masked.nii.gz'):
		try:
			fslmaths_mask=fsl.ApplyMask(in_file=subject, mask_file=mask_file, out_file=subject.split('.nii')[0]+'_masked.nii.gz', output_type='NIFTI_GZ')
			print('running fslmaths -mas '+subject+' ...')
			fslmaths_mask.run()
		except:
			print('WARNING: UNABLE TO RUN fslmaths -mas '+subject+' ...')
