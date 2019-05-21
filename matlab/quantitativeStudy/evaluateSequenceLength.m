% This script performs our evaluation of multi-frame super-resolution for
% different numbers of input frames.

%% Update MATLAB path.
addpath(genpath('../utility'));
addpath(genpath('../algorithms/OpticalFlow'));
addpath(genpath('../algorithms/SRAlgorithms'));

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'sequenceLengthDatasets';
resultDir = '../../results/sequenceLengthDatasets';

% Parameters for this evaluation.
initEvaluationParametersForSequenceLength;

%% Start evaluation.
processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val));