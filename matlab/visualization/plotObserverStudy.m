 %% Setup MATLAB path
addpath('matlab2tikz');
addpath(genpath('../algorithms/SRAlgorithms'));
addpath(genpath('../algorithms/qualityMeasures'));

%% Input and output directories
inputDir = '../../data';
resultDir = '../../results';
outputDir = './';

%% Ranking of SR methods according to their BT scores.
plotBTScores(resultDir, outputDir);

%% Coefficients of agreement between different observers.
plotCoefficientOfAgreement(resultDir, outputDir);

%% Convergence analysis for observer study.
plotObserverStudyConvergence(resultDir, outputDir);

%% Trade-off between computation time and BT scores.
plotQualityTimeTradeoff(resultDir, outputDir);