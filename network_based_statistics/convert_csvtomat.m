% Define the path to your .csv file
csvFilePath = '/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_3cohort-GIMME_paper/NBS/csvfiles_for_designmatrices/HCvFM_cov_none_designmatrix.csv';

% Read the numeric data from the .csv file
data = readmatrix(csvFilePath);

% Define the output .mat file name
outputMatFile = 'HCvFM_cov_none_designmatrix.mat';

% Save the data as a .mat file
save(outputMatFile, 'data'); % outputs to current working directory