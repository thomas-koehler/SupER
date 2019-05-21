function plotQualityMeasuresForMotionTypes(srResults_globalMotion, srResults_mixedMotion, srResults_localMotion, qualityMeasure, binningFactors, srMethods, normalized, outputDir)

    figure_global = plotQualityMeasuresAsBarplot(srResults_globalMotion, qualityMeasure, binningFactors, srMethods, normalized);
    figure_mixed = plotQualityMeasuresAsBarplot(srResults_mixedMotion, qualityMeasure, binningFactors, srMethods, normalized);
    figure_local = plotQualityMeasuresAsBarplot(srResults_localMotion, qualityMeasure, binningFactors, srMethods, normalized);
    LinkFigures([figure_global figure_mixed figure_local]);
    
    if normalized
        qualityMeasure = [qualityMeasure, '_norm'];
    end
    
    % Save to Tikz.
    figure(figure_global);
    matlab2tikz([outputDir, '/', 'baselineDatasets_globalMotion_', qualityMeasure, '.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_mixed);
    matlab2tikz([outputDir, '/', 'baselineDatasets_mixedMotion_', qualityMeasure, '.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_local);
    matlab2tikz([outputDir, '/', 'baselineDatasets_localMotion_', qualityMeasure, '.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
       
    
function figureNumber = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors, srMethods, normalized)
    
    % Compute mean of the quality measure for different SR methods and
    % binning factors.
    barMeans = zeros(length(binningFactors), length(srMethods));
    for binningFactorIdx = 1:length(binningFactors)     
        for srMethodIdx = 1:length(srMethods)
            % Get quality measures for given SR method and binning factor.
            qualityMeasureVals = [srResults([srResults(:).binningFactor] == binningFactors(binningFactorIdx) &  strcmp(srMethods{srMethodIdx}, {srResults(:).srMethod}) > 0).(qualityMeasure)];
            if normalized
                % Normalize the quality measure with the input
                % low-resolution image (after NN interpolation).
                qualityMeasureVals_nn = [srResults([srResults(:).binningFactor] == binningFactors(binningFactorIdx) &  strcmp('nn', {srResults(:).srMethod}) > 0).(qualityMeasure)];
                qualityMeasureVals = (qualityMeasureVals - qualityMeasureVals_nn) ./ abs(qualityMeasureVals_nn);
            end
            
            % Compute the mean of the quality measure.
            barMeans(binningFactorIdx, srMethodIdx) = mean(qualityMeasureVals);        
        end     
    end
    
    % Plot mean quality measures as bar plot.
    figure;
    figureNumber = get(gcf, 'Number');
    bar_handle = bar(barMeans);
    for k = 1:length(srMethods)
        set(bar_handle(k), 'FaceColor', getFaceColorForSRMethod(srMethods{k}));
    end
    hold off;
    pbaspect([4 1.25 1]);
    set(gca, 'XTickLabel', {'2x', '3x', '4x'}, 'XTick', 1:(3*length(srMethods)));
    ymax = max(1.05*max(barMeans(:)));
    ymin = max(0.99*min(barMeans(:)), -0.25*ymax);
    if ymax < ymin
        tmp = ymin;
        ymin = ymax;
        ymax = tmp;
    end
    ylim([ymin ymax]);
    grid on;