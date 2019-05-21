% This script performs our evaluation on simulated datasets obtained from
% our ground truth data.

%% Update MATLAB path.
addpath(genpath('../utility'));
addpath(genpath('../algorithms/OpticalFlow'));
addpath(genpath('../algorithms/SRAlgorithms'));

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'baselineDatasets';
resultDir = '../../results/simulatedDatasets';

% Parameters for this evaluation.
initEvaluationParametersForSimulatedDatasets;

%% Start evaluation.
processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val), 1, true);