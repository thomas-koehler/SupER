% This script evaluates the weighted Kendall tau between the different 
% quality measures (PSNR, SSIM, MSSSIM, IFC, ...) and the BT
% scores obtained from the observer study.

addpath(genpath('../algorithms/SRAlgorithms'));
addpath(genpath('../algorithms/qualityMeasures'));
addpath(genpath('../visualization'));

%% Get results from observer study.
resultDir = '../../results';
motionType = {'global_pan_translation_xyz_inlier', 'local_pan_translation_xyz_inlier', 'local_staticBackground_inlier', 'global_pan_translation_xyz_outlier_photometric'};
binningFactor = [2 3 4];
numberOfFrames = [5 11 17];
qualityMeasureNames = {'psnr', 'ssim', 'msssim', 'ifc', 'lpips', 's3', 'brisque', 'sseq', 'niqe', 'srm'};

%% Correlation coefficients for different motion types.
qualityMeasure = [];
for binningFactorIdx = 1:length(binningFactor)
    for motionTypeIdx = 1:length(motionType)

        % Get BT scores for dataset associated with the current motion type
        % and binning factor.
        load([resultDir, '/observerStudy/btModel.mat']);
        btModel = btModel(strcmp(motionType{motionTypeIdx}, {btModel.motionType}) & [btModel.binningFactor] == binningFactor(binningFactorIdx));

        % Get the quality measures.
        for datasetIdx = 1:length(btModel)       
            if strcmp(motionType{motionTypeIdx}, 'global_pan_translation_xyz_outlier_photometric')
                srResults = getQualityMeasuresFromResults([resultDir, '/photometricOutlierDatasets'], ...
                    {btModel(datasetIdx).scene}, {btModel(datasetIdx).motionType}, {'Uncoded'}, btModel(datasetIdx).binningFactor, [4:14 16], 11, 6);
            else
                srResults = getQualityMeasuresFromResults([resultDir, '/baselineDatasets'], ...
                    {btModel(datasetIdx).scene}, {btModel(datasetIdx).motionType}, {'Uncoded'}, btModel(datasetIdx).binningFactor, 1:length(SRMethods), numberOfFrames(binningFactorIdx));
            end
            
            for srResultIdx = 1:length(srResults)
                for qualityMeasureIdx = 1:length(qualityMeasureNames)            
                    srMethodIdx = getIndexForSRMethodName(string(srResults(srResultIdx).srMethod));
                    qualityMeasure.(qualityMeasureNames{qualityMeasureIdx})(srMethodIdx, datasetIdx) = srResults(srResultIdx).(qualityMeasureNames{qualityMeasureIdx});
                end
            end      
        end
        
        if isempty(srResults)
            continue;
        end

        % Weighted Kendall distance.
        for qualityMeasureIdx = 1:length(qualityMeasureNames)
            for datasetIdx = 1:length(btModel)
                bt = [btModel.scores];
                bt = bt(:,datasetIdx);
                q = qualityMeasure.(qualityMeasureNames{qualityMeasureIdx});
                q = q(:,datasetIdx);
                kendall(motionTypeIdx, binningFactorIdx, qualityMeasureIdx, datasetIdx) = weightedKendallDistance(bt(~isnan(bt)), q(~isnan(bt)), true);
            end
            
        end

    end
end
 
%% Save correlation measures
save([resultDir, '/observerStudy/qualityMeasureCorrelation.mat'], 'kendall', 'motionType', 'binningFactor', 'qualityMeasureNames');