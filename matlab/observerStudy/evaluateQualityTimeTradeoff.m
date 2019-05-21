% Analyze tradeoff between image quality (in terms of mean BT scores) and
% computation times of the different super-resolution algorithms.

%% Get results from observer study.
resultDir = '../../results';
binningFactor = [2 3 4];

%% Get computation times with corresponding BT scores.
for binningFactorIdx = 1:length(binningFactor)
    
    % Get BT scores for the current binning factor.
    load([resultDir, '/observerStudy/btModel.mat']);
    btModel = btModel([btModel.binningFactor] == binningFactor(binningFactorIdx) & ...
        (strcmp('global_pan_translation_xyz_inlier', {btModel.motionType}) ...
        | strcmp('local_pan_translation_xyz_inlier', {btModel.motionType}) ...
        | strcmp('local_staticBackground_inlier', {btModel.motionType})));
    
    % Calculate mean BT scores.
    btScoreMean(:, binningFactorIdx) = mean([btModel.scores], 2, 'omitnan');
    
    % Get computation times for the different SR algorithms.
    for srMethodIdx = 1:size(btScoreMean,1)
        filename = sprintf('%s/timeMeasurements/*bin%s_sr%s_f*.mat', resultDir, num2str(binningFactor(binningFactorIdx)), num2str(srMethodIdx));
        filename = dir(filename);
        load([resultDir, '/timeMeasurements/', filename.name]);
        srTimeTotal(srMethodIdx, binningFactorIdx) = mean(timesTotal);
    end
    
end

%% Save computation times with corresponding BT scores
save([resultDir, '/qualityTimeTradeoff.mat'], 'binningFactor', 'srTimeTotal', 'btScoreMean');