#!/usr/bin/python
# Created by Noah Waller on May 9 2022

from os.path import join as pathjoin
from os.path import sep
from os.path import exists as exists
from os import remove as rm
from glob import glob
import subprocess
from shutil import copyfile 
import pandas as pd

group_dir = '/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_VIS-CORT_paper/act_visual/revisit_cov/cov_sub-OA33-FM33_task-vmr_cov-savb_mask-wb_z3.1_FLAME1+2.gfeat/cope1.feat/extracted_vals_bygroup' #define where extracted text files are stored
output_dir = '/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_VIS-CORT_paper/act_visual/revisit_cov/cov_sub-OA33-FM33_task-vmr_cov-savb_mask-wb_z3.1_FLAME1+2.gfeat/cope1.feat/extracted_vals_bygroup' #define where formated .csv files will be output
file_type = 'zstat' #define cope/varcope/zstat file type

ConArray=["vis", "rest", "visminrest"] #define contrast array to be iterated through, seperated by comma
ROIArray=["RpINS_mask_onlyGM_bin" ] #define array of ROIs to be iterated through, seperated by comma

###
for ROI_abbrev in ROIArray:
	df_full = pd.DataFrame()
	output_name = ROI_abbrev+'_'+file_type+'.csv'
	for con_abbrev in ConArray:
		txtfile_list = glob(pathjoin(group_dir, con_abbrev+'_*_'+ROI_abbrev+'_'+file_type+'.txt'))
		txtfile_list.sort()

		df_txtfiles = pd.DataFrame()
		df_group1 = pd.DataFrame()
		df_group1 = pd.read_csv(txtfile_list[0], delimiter='\r', header=None)
		df_group2 = pd.DataFrame()
		df_group2 = pd.read_csv(txtfile_list[1], delimiter='\r', header=None)

		df_frames = [df_group1, df_group2]
		df_txtfiles = pd.concat(df_frames, axis=1)
		df_txtfiles.columns = ['group1_'+con_abbrev, 'group2_'+con_abbrev]
		
		df_newframes = [df_full, df_txtfiles]
		df_full = pd.concat(df_newframes, axis=1)
		df_full.sort_index(inplace=True, axis=1)
		
		print('Merged and output extracted values for all cohorts from ROI: '+ROI_abbrev+' for task/contrast: '+con_abbrev+' as .csv file')
		
	df_full.to_csv(pathjoin(output_dir, output_name))

###

