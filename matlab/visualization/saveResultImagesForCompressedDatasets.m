%% Update MATLAB path.
% Global path prefix
glob_path_michel = '/CLUSTERHOMES/baetz/lmsSR_framework/src_cvpr_dataset_tests/CVPR/superres/matlab/evaluation/';
glob_path_thomas = '';

glob_path = glob_path_thomas; % IMPORTANT SETTING!

%% Evaluation settings.

% Path to the directory that contains the input data for this evaluation.
inputDir = [glob_path,'../../../data'];
datasetConfig = 'sequenceLengthDatasets';

% Path to the result directory.
resultDir = [glob_path,'../../../results/compressedDatasets'];

% Normal-Execution: Change values manually / Cluster-Execution: Python-controlled variables
% This is the index of the SR method that is evaluated.
sr_method           = 0:20;
% This is the index that indicates the number of input frames.
numberOfFrames_val  = 1;        % PYTHON-CONTROLLED-VARIABLE
% This is the index of the binning factor that is evaluated.
binning_val         = 1:3;      % PYTHON-CONTROLLED-VARIABLE
% This is the index of the scene according to datasets.mat / datasets.xlsx.
scenes_val          = 1:14;     % PYTHON-CONTROLLED-VARIABLE
% This is the index of the slidng window that is evaluated.
sliding_val         = 1;        % PYTHON-CONTROLLED-VARIABLE
% This is the index of the compression setting
compress_val        = 1:5;      % PYTHON-CONTROLLED-VARIABLE

%% Start evaluation.

% Compression settings (index 1 means uncoded; indices 2-5 mean coded with the corresponding QP setting)
compressions   = [NaN, 10, 20, 30, 40]; % Hybrid coder H.265/HEVC is employed
% Binning factors used for this evaluation.
binningFactors = [2, 3, 4];
% Number of frames used for super-resolution at the different binning
% factors.
numberOfFrames = [5, ...    % Number of frames for binning factor 2
                  11, ...   % Number of frames for binning factor 3
                  17];      % Number of frames for binning factor 4

% Run evaluation with the current configuration.
saveResultImages(inputDir, datasetConfig, resultDir, compressions, binningFactors, numberOfFrames, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compress_val);