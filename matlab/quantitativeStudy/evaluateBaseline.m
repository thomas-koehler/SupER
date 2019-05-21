% This script performs our evaluation on the global, local, and mixed
% motion datasets.

%% Update MATLAB path.
addpath(genpath('../utility'));
addpath(genpath('../algorithms/OpticalFlow'));
addpath(genpath('../algorithms/SRAlgorithms'));

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'baselineDatasets';
resultDir = '../../results/baselineDatasets';

% Parameters for this evaluation.
initEvaluationParametersForBaseline;

%% Start evaluation.
processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val));