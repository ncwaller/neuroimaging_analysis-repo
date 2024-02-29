#!/usr/bin/python

# similar to formatting the extracted values, this script formats a full extracted time series in a .csv file

from os.path import join as pathjoin
from glob import glob
import pandas as pd

data_dir= #defines data dir
output_dir= #defines where formated .csv files will be output
mask_dir= #defines where mask is located
mask = 'ROI_1' #defines mask used for time series extraction
output_name = mask+'_merged_ts.csv'

###
textfile_list = glob(pathjoin(data_dir, 'sub*_'+mask+'*.txt'))
textfile_list.sort()

df_full = pd.DataFrame()
for textfile in textfile_list:
	subj_name = textfile.split('/')[-1].split('_')[-4]
	df_current = pd.DataFrame()
	df_current = pd.read_csv(textfile, delimiter='\r', header=None)
	df_current.columns = [subj_name]

	df_frames = [df_full, df_current]
	df_full = pd.concat(df_frames, axis=1)

df_full.to_csv(pathjoin(output_dir, output_name))
	
print('Merged extracted mean time series values for '+mask)
###
