% This script calculates full-reference and no-reference quality measures
% on the compression datasets.

%% Update MATLAB path.
addpath('../algorithms/SRAlgorithms');
addpath('../algorithms/qualityMeasures');

%% Evaluation settings.

% Path to input data and result directory.
inputDir = '../../data';
datasetConfig = 'compressionDatasets';
resultDir = '../../results/compressionDatasets';

% Parameters for this evaluation.
initEvaluationParametersForCompression;

% The quality measures that are calculated.
measure_val = 1:length(qualityMeasures);

% Size of the border in pixels that is cropped from super-resolved image to 
% evaluate the quality measures without distortion by boundary artifacts.
border = 3;

%% Start evaluation.
calculateQualityMeasures(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, numberOfFrames_val, sliding_val, sr_method, binning_val, scenes_val, compressions(compress_val), measure_val, border);
