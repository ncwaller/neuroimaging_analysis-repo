
#!/usr/bin/python

# Created by Ishtiaq, edited by Noah Waller Jun 15 2023

from os.path import join as pathjoin
from os.path import sep
from os.path import dirname as get_dirname
from os.path import exists
from os import makedirs as mkdir
from os import chdir as cd
from glob import glob
from nipype.interfaces import fsl
from nipype.interfaces import afni
import ntpath
from scipy.io import savemat
import numpy as np
from nilearn.input_data import NiftiMapsMasker
from nilearn.connectome import ConnectivityMeasure
from nilearn.connectome import sym_matrix_to_vec, vec_to_sym_matrix

script_dir=pathjoin(sep, 'PROJECTS', 'REHARRIS', 'noah', 'analysis_CORTmicapp', 'analysis_3cohort-GIMME_paper', 'local_atlas_info')
data_dir = pathjoin(sep, 'PROJECTS', 'REHARRIS', 'noah', 'analysis_CORTmicapp', 'analysis_3cohort-GIMME_paper', 'CORT_all_vis_files')
nii_list = glob(pathjoin(data_dir, 'sub-*task-visualrun01*aCompCor6par6_masked.nii.gz'))
nii_list.sort()

atlas_filename='/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_3cohort-GIMME_paper/local_atlas_info/merged_atlas_forconn/Schaefer200_MSAS2_merged.nii.gz'
parcellation='Schaefer200_MSAS2'

if not exists(pathjoin(script_dir, 'connectome', parcellation)):
	mkdir(pathjoin(script_dir, 'connectome', parcellation))

cd(pathjoin(script_dir, 'connectome', parcellation))

for nii_file in nii_list:
	masker = NiftiMapsMasker(maps_img=atlas_filename, standardize=True)
	time_series = masker.fit_transform(nii_file)
	correlation_measure = ConnectivityMeasure(kind='correlation')
	correlation_matrix = correlation_measure.fit_transform([time_series])[0]
	# fisher z-transform
	vectorize_array = sym_matrix_to_vec(symmetric = correlation_matrix, discard_diagonal=False)
	fisher_vectorize_array = np.arctanh(vectorize_array)
	fisher_transform_matrix = vec_to_sym_matrix(vec = fisher_vectorize_array, diagonal=None)
	# save outputs
	np.savetxt(ntpath.basename(nii_file).split('.nii')[0]+'_connmat_ztrans.txt', fisher_transform_matrix)
	savemat(ntpath.basename(nii_file).split('.nii')[0]+'_connmat_ztrans.mat', {'correlationmatrix':fisher_transform_matrix})
	#np.savetxt(pathjoin(data_dir, 'ztrans')+'/'+ntpath.basename(connectome).split('.txt')[0]+'_ztrans.txt', fisher_transform_matrix)
	#savemat(pathjoin(data_dir, 'ztrans')+'/'+ntpath.basename(connectome).split('.txt')[0]+'_ztrans.mat', {'correlationmatrix':fisher_transform_matrix})
	print('computed connectome for '+nii_file)

