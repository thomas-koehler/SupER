function plotQualityMeasuresForCompressedDatasets(srResults, qualityMeasure, binningFactors, compression, srMethods, normalized, outputDir)
    
    figure_bin2 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(1), srMethods, compression, normalized);
    figure_bin3 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(2), srMethods, compression, normalized);
    figure_bin4 = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactors(3), srMethods, compression, normalized);
    LinkFigures([figure_bin2 figure_bin3 figure_bin4]);
    
    if normalized
        qualityMeasure = [qualityMeasure, '_norm'];
    end
    
    % Save to Tikz.
    figure(figure_bin2);
    matlab2tikz([outputDir, '/', 'compressionDatasets_bin2_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_bin3);
    matlab2tikz([outputDir, '/', 'compressionDatasets_bin3_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    figure(figure_bin4);
    matlab2tikz([outputDir, '/', 'compressionDatasets_bin4_', qualityMeasure, '_bars.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
          
function figureNumber = plotQualityMeasuresAsBarplot(srResults, qualityMeasure, binningFactor, srMethods, compression, normalized)
    
    % Compute mean of the quality measure for different SR methods and
    % binning factors.
    barMeans = zeros(length(compression), length(srMethods));
    for compressionLevelIdx = 1:length(compression)
        for srMethodIdx = 1:length(srMethods)
            % Get quality measures for given SR method and binning factor.
            qualityMeasureVals = [srResults([ strcmp({srResults.compressionLevel}, compression{compressionLevelIdx}) ] ...
                & [srResults(:).binningFactor] == binningFactor ...
                &  strcmp(srMethods{srMethodIdx}, {srResults(:).srMethod}) > 0).(qualityMeasure)];
            
            if normalized
                % Normalize the quality measure with the input
                % low-resolution image (after NN interpolation).
                qualityMeasureVals_nn = [srResults([ strcmp({srResults.compressionLevel}, compression{compressionLevelIdx}) ] ...
                    & [srResults(:).binningFactor] == binningFactor &  strcmp('nn', {srResults(:).srMethod}) > 0).(qualityMeasure)];
                qualityMeasureVals = (qualityMeasureVals - qualityMeasureVals_nn) ./ abs(qualityMeasureVals_nn);
            end
            
            % Compute the mean of the quality measure.
            barMeans(compressionLevelIdx, srMethodIdx) = mean(qualityMeasureVals);
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
    set(gca, 'XTickLabel', {'Uncoded', 'QP10', 'QP20', 'QP30', 'QP40'}, 'XTick', 1:(5*length(srMethods)));
    ymax = max(1.05*max(barMeans(:)));
    ymin = max(0.99*min(barMeans(:)), -0.25*ymax);
    ylim([ymin ymax]);
    ylabelStr = upper(qualityMeasure);
    if normalized
        ylabelStr = ['Norm. ', ylabelStr]; %#ok<AGROW>
    end
    ylabel(ylabelStr);
    grid on;