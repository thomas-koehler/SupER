% This script evaluates the convergence of the observer study in terms of the
% Kendall coefficients of agreement versus different numbers of observers and
% error thresholds for the sanity checks.

%% Get results from observer study.
resultDir = '../../results';
load([resultDir, '/observerStudy/voting.mat']);

%% Monte-Carlo simulation
maxSanityCheckFails = [0 1 8];
numWorkers = linspace(500, 4000, 21);
numSamples = 1000;
kendall = NaN(length(maxSanityCheckFails), length(numWorkers), numSamples);

for maxSanityCheckFailsIdx = 1:length(maxSanityCheckFails)
    
    % Perform sanity check with the current threshold.
    sanityCheckPassed = performSanityCheck(imagePairs, maxSanityCheckFails(maxSanityCheckFailsIdx));
    imagePairsCheckPassed = imagePairs(sanityCheckPassed);
    
    % Evaluate based on different numbers of image pairs.
    for numWorkersIdx = 1:length(numWorkers)
        
        % Create random samples.
        for sampleIdx = 1:numSamples
            % Draw random subset from the image pairs.
            rperm = randperm(length(imagePairsCheckPassed), numWorkers(numWorkersIdx));
            imagePairsSubset = imagePairsCheckPassed(rperm);

            % Kendall coefficient of agreement based on the current subset.
            kendall(maxSanityCheckFailsIdx, numWorkersIdx, sampleIdx) = coefficientOfAgreement( createWinningMatrix( selectImagePairs(imagePairsSubset) ) );
        end
        
    end

end

%% Save standard deviation of BT scores.
save([resultDir, '/observerStudy/observerStudyConvergence.mat'], 'maxSanityCheckFails', 'numWorkers', 'numSamples', 'kendall');