% This script plots the mean BT scores of competing SR algorithms. 
function plotBTScores(resultDir, outputDir)
    
    % Get precomputed BT scores.
    load([resultDir, '/observerStudy/btModel.mat']);
    
    % Plot BT scores for different motion types.
    motionType = {'global_pan_translation_xyz_inlier', 'local_pan_translation_xyz_inlier', 'local_staticBackground_inlier', 'global_pan_translation_xyz_outlier_photometric'};
    
    colorMap = jet(30);
    faceColor_sisr = colorMap(1:10,:);
    faceColor_mfsr = colorMap(21:30,:);
    srMethods = SRMethods;
    sisrColorIdx = 1;
    mfsrColorIdx = 1;
    for k = 1:length(srMethods)
        if strcmp(srMethods(k).type, 'sisr')
            faceColor(k,:) = faceColor_sisr(sisrColorIdx,:);
            sisrColorIdx = sisrColorIdx + 1;
        else
            faceColor(k,:) = faceColor_mfsr(mfsrColorIdx,:);
            mfsrColorIdx = mfsrColorIdx + 1;
        end    
    end
    
    for motionTypeIdx = 1:length(motionType)
        
        % Get the BT scores for the current motion type.
        bt = btModel(strcmp({btModel.motionType}, motionType{motionTypeIdx}));
        [bt, srMethodIndices] = sort(mean([bt.scores], 2, 'omitnan'), 'descend');
        
        % Discard SR methods with NaN scores.
        srMethodIndices = srMethodIndices(~isnan(bt));
        bt = bt(~isnan(bt));
        
        % Get names of the SR methods.
        srMethods = SRMethods;
        srMethodNames = {srMethods(srMethodIndices).name};
        srMethodTypes = {srMethods(srMethodIndices).type};
        
        % Plot BT scores as bar diagram.
        figure;
        for k = 1:length(srMethodNames)
             if strcmp(srMethodTypes{length(srMethodNames)-k+1}, 'sisr')
                barh(k, bt(length(srMethodNames)-k+1), 'FaceColor', faceColor(srMethodIndices(length(srMethodNames)-k+1), :));
             else
                 barh(k, bt(length(srMethodNames)-k+1), 'FaceColor', faceColor(srMethodIndices(length(srMethodNames)-k+1), :));
             end
             hold on;
        end
        grid on;
        set(gca, 'YTick', 1:length(srMethodNames), 'YTickLabel', upper(srMethodNames(end:-1:1)));
        xlabel('Mean B-T score $\bar{\delta}$', 'interpreter', 'latex');
        ylim([0 length(srMethodNames)+1]);
        
        % Save to TikZ.
        switch motionType{motionTypeIdx}
            case 'global_pan_translation_xyz_inlier'
                outputName = 'globalMotion';
            case 'local_pan_translation_xyz_inlier'
                outputName = 'mixedMotion';
            case 'local_staticBackground_inlier'
                outputName = 'localMotion';
            case 'global_pan_translation_xyz_outlier_photometric'
                outputName = 'photometricVariation';
        end
        matlab2tikz([outputDir, '/', 'btScores_', outputName, '.tikz'], ...
            'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
            'extraaxisoptions', ['xlabel near ticks,', ...
            'ylabel near ticks,', ...
            'scaled y ticks=false,', ...
            'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    end