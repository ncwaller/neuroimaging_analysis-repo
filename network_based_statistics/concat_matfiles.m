% Define the directory containing the .mat files
inputDirectory = '/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_3cohort-GIMME_paper/local_atlas_info/connectome/HCvFM_cov_none';

% Define the output directory for the concatenated .mat file
outputDirectory = '/PROJECTS/REHARRIS/noah/analysis_CORTmicapp/analysis_3cohort-GIMME_paper/NBS';

% Get a list of all .mat files in the input directory
matFiles = dir(fullfile(inputDirectory, '*.mat'));

% Initialize an empty cell array to hold the 2D matrices
matrices = {};

% Loop through each .mat file and load the data
for i = 1:length(matFiles)
    % Load the .mat file
    data = load(fullfile(inputDirectory, matFiles(i).name));
    
    % Assume the variable name in the .mat file is 'dataMatrix'
    % Change 'dataMatrix' to the actual variable name in your .mat files
    matrix = data.correlationmatrix;
    
    % Add the loaded matrix to the cell array
    matrices{end+1} = matrix;
end

% Convert the cell array to a 3D array
if ~isempty(matrices)
    % Get the size of the first matrix
    [rows, cols] = size(matrices{1});
    
    % Initialize a 3D array with the appropriate size
    concatenatedData = zeros(rows, cols, length(matrices));
    
    % Fill the 3D array with the matrices
    for i = 1:length(matrices)
        concatenatedData(:, :, i) = matrices{i};
    end
    
    % Save the 3D array to a new .mat file in the output directory
    save(fullfile(outputDirectory, 'HCvFM_cov_none_concat.mat'), 'concatenatedData'); % Change output file name
else
    disp('No .mat files found in the directory.');
end