% This script performs our computation time evaluation.

%% Update MATLAB path.
addpath(genpath('../utility'));
addpath(genpath('../algorithms/OpticalFlow'));
addpath(genpath('../algorithms/SRAlgorithms'));

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'timingDatasets';
resultDir = '../../results/timeMeasurements';

% Parameters for this evaluation.
initEvaluationParametersForComputationTime;

%% Start evaluation.
num_timing_tests = 5;
processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val), num_timing_tests);