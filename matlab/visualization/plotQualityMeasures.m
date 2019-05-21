%% Setup MATLAB path
addpath('matlab2tikz');
addpath(genpath('../algorithms/SRAlgorithms'));
addpath(genpath('../algorithms/qualityMeasures'));

%% Input and output directories
inputDir = '../../data';
resultDir = '../../results';
outputDir = './';

%% Global motion, mixed motion and local motion benchmark
srMethods = {'bicubic', 'ebsr', 'scsr', 'nbsrf', 'aplus', 'srcnn', 'drcn', 'vdsr', 'sesr', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bepsr', 'irwsr', 'bvsr', 'srb', 'vsrnet'};
binningFactors = [2, 3, 4];
numberOfFrames = [5, 11, 17];
slidingWindows = 1:10;
qualityMeasures = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips', 's3', 'brisque', 'sseq', 'niqe', 'srm'};

% Get SR results with quality measures.
srResults_globalMotion = getQualityMeasuresFromResults([resultDir, '/baselineDatasets'], {}, {'global_translation_z_inlier', 'global_translation_xz_inlier', 'global_pan_inlier', 'global_pan_translation_xyz_inlier'}, {'Uncoded'}, binningFactors, 1:length(SRMethods), numberOfFrames, slidingWindows);
srResults_mixedMotion = getQualityMeasuresFromResults([resultDir, '/baselineDatasets'], {}, {'local_translation_z_inlier', 'local_translation_xz_inlier', 'local_pan_inlier', 'local_pan_translation_xyz_inlier'}, {'Uncoded'}, binningFactors, 1:length(SRMethods), numberOfFrames, slidingWindows);
srResults_localMotion = getQualityMeasuresFromResults([resultDir, '/baselineDatasets'], {}, {'local_staticBackground_inlier'}, {'Uncoded'}, binningFactors, 1:length(SRMethods), numberOfFrames, slidingWindows);

for qualityMeasureIdx = 1:length(qualityMeasures)    
    plotQualityMeasuresForMotionTypes(srResults_globalMotion, srResults_mixedMotion, srResults_localMotion, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, true, outputDir);
    plotQualityMeasuresForMotionTypes(srResults_globalMotion, srResults_mixedMotion, srResults_localMotion, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, false, outputDir);
end

%% Photometric outlier benchmark
srMethods = {'bicubic', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bvsr', 'bepsr', 'srb', 'irwsr'};
binningFactors = [2, 3, 4];
numberOfFrames = [11, 11, 11];
slidingWindows = 1:6;
compression = {'Uncoded'};
qualityMeasures = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips', 's3', 'brisque', 'sseq', 'niqe', 'srm'};

% Get SR results with quality measures.
srResults_photometric = getQualityMeasuresFromResults([resultDir, '/photometricOutlierDatasets'], {}, {'global_pan_translation_xyz_outlier_photometric'}, compression, binningFactors, [5:14 16], numberOfFrames, slidingWindows);

for qualityMeasureIdx = 1:length(qualityMeasures) 
    plotQualityMeasuresForPhotometricOutlierDatasets(srResults_photometric, qualityMeasures{qualityMeasureIdx}, binningFactors, slidingWindows-1, srMethods, true, outputDir);
    plotQualityMeasuresForPhotometricOutlierDatasets(srResults_photometric, qualityMeasures{qualityMeasureIdx}, binningFactors, slidingWindows-1, srMethods, false, outputDir);
end

%% Compression datasets benchmark
srMethods = {'bicubic', 'ebsr', 'scsr', 'nbsrf', 'aplus', 'srcnn', 'drcn', 'vdsr', 'sesr', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bepsr', 'irwsr', 'bvsr', 'srb', 'vsrnet'};

binningFactors = [2, 3, 4];
compression = {'Uncoded', 'H265QP10', 'H265QP20', 'H265QP30', 'H265QP40'};
qualityMeasures = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips', 's3', 'brisque', 'sseq', 'niqe', 'srm'};

% Get SR results with quality measures.
srResults_compression = getQualityMeasuresFromResults([resultDir, '/compressionDatasets'], {}, {'global_pan_translation_xyz_inlier'}, compression, binningFactors);

for qualityMeasureIdx = 1:length(qualityMeasures) 
    plotQualityMeasuresForCompressedDatasets(srResults_compression, qualityMeasures{qualityMeasureIdx}, binningFactors, compression, srMethods, true, outputDir);
    plotQualityMeasuresForCompressedDatasets(srResults_compression, qualityMeasures{qualityMeasureIdx}, binningFactors, compression, srMethods, false, outputDir);
end

%% Sequence length benchmark
srMethods = {'bicubic', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bvsr', 'bepsr', 'srb', 'irwsr'};
binningFactors = [2, 3, 4];
numberOfFrames = [(3:4:19).', (3:4:19).', (3:4:19).'];
compression = {'Uncoded'};
qualityMeasures = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips', 's3', 'brisque', 'sseq', 'niqe', 'srm'};

% Get SR results with quality measures.
srResults_sequenceLength = getQualityMeasuresFromResults([resultDir, '/sequenceLengthDatasets'], {}, {'global_pan_translation_xyz_inlier'}, compression, binningFactors, [5:14 16], numberOfFrames, 1);

for qualityMeasureIdx = 1:length(qualityMeasures) 
    plotQualityMeasuresForSequenceLengthDatasets(srResults_sequenceLength, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, true, outputDir);
    plotQualityMeasuresForSequenceLengthDatasets(srResults_sequenceLength, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, false, outputDir);
end

%% Correlation of simulated data to real data
srMethods = {'ebsr', 'scsr', 'nbsrf', 'aplus', 'srcnn', 'drcn', 'vdsr', 'sesr', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bepsr', 'irwsr', 'vsrnet'};
binningFactors = [2, 3, 4];
numberOfFrames = [5, 11, 17];
slidingWindows = 1;
compression = {'Uncoded'};
qualityMeasures = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips'};

% Get SR results with quality measures.
srResults_simulated = getQualityMeasuresFromResults([resultDir '/simulatedDatasets'], {}, {'global_pan_translation_xyz_inlier'}, compression, binningFactors, 1:length(SRMethods), numberOfFrames, slidingWindows, [1:4 10]);
srResults_real = getQualityMeasuresFromResults([resultDir '/baselineDatasets'], {}, {'global_pan_translation_xyz_inlier'}, compression, binningFactors, 1:length(SRMethods), numberOfFrames, slidingWindows, [1:4 10]);

for qualityMeasureIdx = 1:length(qualityMeasures) 
    plotSimulatedToRealDataCorrelation(srResults_simulated, srResults_real, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, true, outputDir);
    plotSimulatedToRealDataCorrelation(srResults_simulated, srResults_real, qualityMeasures{qualityMeasureIdx}, binningFactors, srMethods, false, outputDir);
end