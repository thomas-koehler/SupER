function plotQualityMeasuresForSequenceLengthDatasets(srResults, qualityMeasure, binningFactors, srMethods, normalized, outputDir)
    
    for binningFactorIdx = 1:length(binningFactors)     
        
        % Create new line plot.
        figure;
        
        for srMethodIdx = 1:length(srMethods)        
            % Get number of frames from the SR results.
            numberOfFrames = [srResults([srResults(:).binningFactor] == binningFactors(binningFactorIdx) ...
                &  strcmp(srMethods{srMethodIdx}, {srResults(:).srMethod}) > 0).numberOfFrames];
            numberOfFrames = unique(numberOfFrames);
            
            % Compute mean of the quality measure for the different
            % sequence lengths.
            for numberOfFramesIdx = 1:length(numberOfFrames)
                % Get quality measures for given SR method and binning factor.
                qualityMeasureVals = [srResults([srResults(:).numberOfFrames] == numberOfFrames(numberOfFramesIdx) ...
                    & [srResults(:).binningFactor] == binningFactors(binningFactorIdx) &  strcmp(srMethods{srMethodIdx}, {srResults(:).srMethod}) > 0).(qualityMeasure)];
                
                if normalized
                    % Normalize the quality measure with the input
                    % low-resolution image (after NN interpolation).
                    qualityMeasureVals_nn = [srResults([srResults(:).numberOfFrames] == numberOfFrames(numberOfFramesIdx) ...
                        & [srResults(:).binningFactor] == binningFactors(binningFactorIdx) &  strcmp('nn', {srResults(:).srMethod}) > 0).(qualityMeasure)];
                    qualityMeasureVals = (qualityMeasureVals - qualityMeasureVals_nn) ./ abs(qualityMeasureVals_nn);
                end
            
                qualityMeasureMeans(srMethodIdx, numberOfFramesIdx) = mean(qualityMeasureVals); %#ok<AGROW>
            end
            
            % Line plot for the current SR method.
            [facecolor, linestyle, marker] = getFaceColorForSRMethod(srMethods{srMethodIdx});
            plot(numberOfFrames, qualityMeasureMeans(srMethodIdx, :), [linestyle marker], 'Color', facecolor, 'LineWidth', 1.0);
            hold on;     
        end
        
        % Format axis.
        grid on;
        xlim([numberOfFrames(1) numberOfFrames(end)]);
        
        % Add label for x- and y-axis.
        xlabel('Number of frames');
        ylabelStr = upper(qualityMeasure);
        if normalized
            ylabelStr = ['Norm. ', ylabelStr]; %#ok<AGROW>
        end
        ylabel(ylabelStr);
        
        % Save to tikz.
        qualityMeasureStr = qualityMeasure;
        if normalized
            qualityMeasureStr = [qualityMeasure, '_norm']; 
        end
        
        matlab2tikz([outputDir, '/sequenceLength_bin', num2str(binningFactors(binningFactorIdx)), '_', qualityMeasureStr, '.tikz'], ...
            'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
            'extraaxisoptions', ['xlabel near ticks,', 'ylabel near ticks,', 'scaled y ticks=false,', 'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
        
    end