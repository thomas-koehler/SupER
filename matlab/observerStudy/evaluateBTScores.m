% This script fits the Bradley-Terry (BT) models for the set of images
% included in our observer study.

addpath(genpath('../algorithms/SRAlgorithms'));

%% Get results from observer study.
resultDir = '../../results';
scenes = importdata([resultDir, '/observerStudy/scenes.csv']);
load([resultDir, '/observerStudy/voting.mat']);

%% Perform sanity check.
maxSanityCheckFails = 1;
sanityCheckPassed = performSanityCheck(imagePairs, maxSanityCheckFails);
imagePairs = imagePairs(sanityCheckPassed);

%% Fit Bradley-Terry (BT) models. 
motionType = {'global_pan_translation_xyz_inlier', 'local_pan_translation_xyz_inlier', 'local_staticBackground_inlier', 'global_pan_translation_xyz_outlier_photometric'};
binningFactor = [2 3 4];

datasetIdx = 1;
for sceneIdx = 1:length(scenes)
    for motionTypeIdx = 1:length(motionType)    
        for binningFactorIdx = 1:length(binningFactor)
            
            % Get winning matrix for current dataset
            winningMatrix = createWinningMatrix( selectImagePairs(imagePairs, scenes{sceneIdx}, motionType{motionTypeIdx}, binningFactor(binningFactorIdx)) );
            
            % Fit the BT model.
            s = fitBTModel(winningMatrix);
            % Normalize the BT scores to zero mean.
            s = s - mean(s(~isnan(s)));
            
            btModel(datasetIdx).scene = scenes{sceneIdx};
            btModel(datasetIdx).motionType = motionType{motionTypeIdx};
            btModel(datasetIdx).binningFactor = binningFactor(binningFactorIdx);
            btModel(datasetIdx).scores = s;
            
            datasetIdx = datasetIdx + 1;
        end     
    end  
end

%% Save BT models.
save([resultDir, '/observerStudy/btModel.mat'], 'btModel');