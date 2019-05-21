% This plots the weighted Kendall tau distance among the quantitative image
% quality measures (PSNR, SSIM, MSSSIM, IFC, ...) and the BT scores obtained 
% from the observer study.
function plotQualityMeasureCorrelations(resultDir, outputDir)

    % Get precomputed coefficients.
    load([resultDir, '/observerStudy/qualityMeasureCorrelation.mat']);
    
    faceColor = [winter(5); autumn(5)];
    for motionTypeIdx = 1:length(motionType)    
        
        % Get mean values for each binning factor.
        for binningFactorIdx = 1:length(binningFactor)
            kendallMean(binningFactorIdx,:) = mean(squeeze(kendall(motionTypeIdx,binningFactorIdx,:,:)), 2, 'omitnan');
        end
        
        % Bar diagram for current motion type.
        figure;
        bar_handle = bar(binningFactor, kendallMean); 
        for k = 1:length(bar_handle)
            set(bar_handle(k), 'FaceColor', faceColor(k,:));
        end
        grid on;
        ylim([0 1.0]);
        ylabel('Mean weighted Kendall $\tau$', 'interpreter', 'latex');
        xticklabels({'2x', '3x', '4x'});
                
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
        matlab2tikz([outputDir, '/', 'weightedKendallDistance_', outputName, '.tikz'], ...
            'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
            'extraaxisoptions', ['xlabel near ticks,', ...
            'ylabel near ticks,', ...
            'scaled y ticks=false,', ...
            'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
        
    end