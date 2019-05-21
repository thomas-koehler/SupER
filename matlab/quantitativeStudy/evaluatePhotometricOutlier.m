% This script performs our evaluation on the photometric variation datasets
% with different numbers of photometric outliers.

%% Update MATLAB path.
addpath(genpath('../utility'));
addpath(genpath('../algorithms/OpticalFlow'));
addpath(genpath('../algorithms/SRAlgorithms'));

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'photometricOutlierDatasets';
resultDir = '../../results/photometricOutlierDatasets';

% Parameters for this evaluation.
initEvaluationParametersForPhotometricOutlier;

%% Start evaluation.
processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val));