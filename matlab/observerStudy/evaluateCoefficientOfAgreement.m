% This script calculates the Kendall coefficients of agreement at different
% motion types and binning factors based on the image pairs included in the
% observer study.

%% Get results from user study.
resultDir = '../../results';
load([resultDir, '/observerStudy/voting.mat']);

%% Perform sanity check.
maxSanityCheckFails = 1;
sanityCheckPassed = performSanityCheck(imagePairs, maxSanityCheckFails);
imagePairs = imagePairs(sanityCheckPassed);
        
%% Calculate Kendall coefficients of agreement.
% The motion types and binning factors considered in this study.
motionType = {'global_pan_translation_xyz_inlier', 'local_pan_translation_xyz_inlier', 'local_staticBackground_inlier', 'global_pan_translation_xyz_outlier_photometric'};
binningFactor = [2 3 4];

numBinningFactors = length(binningFactor);
numMotionTypes = length(motionType);
kendall = NaN(numBinningFactors, numMotionTypes);
for binningFactorIdx = 1:numBinningFactors
    for motionTypeIdx = 1:numMotionTypes
        
        % Select image pairs for the given motion type.
        imagePairsSel = selectImagePairs(imagePairs, {}, motionType{motionTypeIdx}, binningFactor(binningFactorIdx));
        if isempty(imagePairsSel)
            continue;
        end
        
        % Construct the winning matrix.
        winningMatrix = createWinningMatrix(imagePairsSel);
    
        % Calculate Kendall coefficient of agreement.
        kendall(binningFactorIdx, motionTypeIdx) = coefficientOfAgreement(winningMatrix);
    end
end

%% Save coefficients of agreement.
save([resultDir, '/observerStudy/coefficientsOfAgreement.mat'], 'kendall', 'motionType', 'binningFactor');