function plotQualityMeasuresForPhotometricOutlierDatasets(srResults, qualityMeasure, binningFactors, numberOfOutlierFrames, srMethods, normalized, outputDir)
    
    figure_bin2 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(1), srMethods, numberOfOutlierFrames, normalized);
    figure_bin3 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(2), srMethods, numberOfOutlierFrames, normalized);
    figure_bin4 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(3), srMethods, numberOfOutlierFrames, normalized);
    LinkFigures([figure_bin2 figure_bin3 figure_bin4]);
    
    if normalized
        qualityMeasure = [qualityMeasure, '_norm'];
    end
    
    % Save to Tikz.
    figure(figure_bin2);
    matlab2tikz([outputDir, '/', 'photometricOutlierDatasets_bin2_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_bin3);
    matlab2tikz([outputDir, '/', 'photometricOutlierDatasets_bin3_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_bin4);
    matlab2tikz([outputDir, '/', 'photometricOutlierDatasets_bin4_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);

function figureNumber = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactor, srMethods, numberOfOutlierFrames, normalized)
    
    % Compute mean of the quality measure for different SR methods and
    % binning factors.            
    barMeans = zeros(length(length(numberOfOutlierFrames)), length(srMethods));
    for numberOfOutlierFramesIdx = 1:length(numberOfOutlierFrames)
        for srMethodIdx = 1:length(srMethods)
            % Get quality measures for given SR method and binning factor.
            qualityMeasureVals = [srResults([srResults(:).slidingWindow] == (numberOfOutlierFrames(numberOfOutlierFramesIdx) + 1) ...
                    & [srResults(:).binningFactor] == binningFactor &  strcmp(srMethods{srMethodIdx}, {srResults(:).srMethod}) > 0).(qualityMeasure)];
            
            if normalized
                qualityMeasureVals_nn = [srResults([srResults(:).slidingWindow] == (numberOfOutlierFrames(numberOfOutlierFramesIdx) + 1) ...
                        & [srResults(:).binningFactor] == binningFactor &  strcmp('nn', {srResults(:).srMethod}) > 0).(qualityMeasure)];
                qualityMeasureVals = (qualityMeasureVals - qualityMeasureVals_nn) ./ abs(qualityMeasureVals_nn); 
            end
            
            % Compute the mean of the quality measure.
            barMeans(numberOfOutlierFramesIdx, srMethodIdx) = mean(qualityMeasureVals);
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
    set(gca, 'XTickLabel', string(numberOfOutlierFrames), 'XTick', 1:length(numberOfOutlierFrames));
    ymax = max(1.05*max(barMeans(:)));
    ymin = max(0.99*min(barMeans(:)), -0.25*ymax);
    if ymax < ymin
        tmp = ymin;
        ymin = ymax;
        ymax = tmp;
    end
    ylim([ymin ymax]);
    ylabelStr = upper(qualityMeasure);
    if normalized
        ylabelStr = ['Norm. ', ylabelStr]; %#ok<AGROW>
    end
    ylabel(ylabelStr);
    grid on;