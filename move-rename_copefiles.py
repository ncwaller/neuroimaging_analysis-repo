#!/usr/bin/python

# moves and renames contrast of parameter estimate files from first level FEAT output directory - critical for second level analyses

from os.path import join as pathjoin
from os.path import sep
from os.path import exists as exists
from os import remove as rm
from glob import glob
import subprocess
from shutil import copyfile

pdir = #insert parent directory (to copy from)
destinationdir = #insert destination dir (to copy to)
mask = #insert path to mask file

contrasts = {'cope1': 'restminvis', 'cope2': 'visminrest', 'cope3': 'rest', 'cope4': 'vis'}  #define cope-to-task block (depends on first level parameters)

for key, value in contrasts.items():
	#copy paste cope, varcope, and zstat from individual first level feat
	cope_list = glob(pathjoin(pdir, 'sub-mic*_task-visual*.feat', 'stats', key+'.nii.gz'))
	cope_list.sort()
	for cope in cope_list:
		subtask=cope.split('/')[-3].split('.')[0]
		newcopefile='cope_'+subtask+'_'+'con-'+value+'.nii.gz'
		varcope=cope.replace('cope','varcope')
		newvarcopefile='varcope_'+subtask+'_'+'con-'+value+'.nii.gz'
		zstat=cope.replace('cope','zstat')
		newzstatfile='zstat_'+subtask+'_'+'con-'+value+'.nii.gz'
		if not exists(newcopefile):
			copyfile(cope, pathjoin(destinationdir, newcopefile))
		if not exists(newvarcopefile):
			copyfile(varcope, pathjoin(destinationdir, newvarcopefile))
		if not exists(newzstatfile):
			copyfile(zstat, pathjoin(destinationdir, newzstatfile))

