function plotSimulatedToRealDataCorrelation(srResults_simulated, srResults_real, qualityMeasure, binningFactors, srMethods, normalized, outputDir)

    for binningFactorIdx = 1:length(binningFactors)
    
        % Create new line plot.
        figure;
        
        qm_simulated_mean = zeros(1, length(srMethods));
        qm_real_mean = zeros(1, length(srMethods));
        for srMethodIdx = 1:length(srMethods)  
            % Get quality measure for simulated and real data.
            qm_simulated = [srResults_simulated([srResults_simulated(:).binningFactor] == binningFactors(binningFactorIdx) ...
                &  strcmp(srMethods{srMethodIdx}, {srResults_simulated(:).srMethod}) > 0).(qualityMeasure)]; 
            qm_real = [srResults_real([srResults_real(:).binningFactor] == binningFactors(binningFactorIdx) ...
                &  strcmp(srMethods{srMethodIdx}, {srResults_real(:).srMethod}) > 0).(qualityMeasure)];
            
            if normalized
                qm_nn_simulated = [srResults_simulated([srResults_simulated(:).binningFactor] == binningFactors(binningFactorIdx) ...
                    &  strcmp('nn', {srResults_simulated(:).srMethod}) > 0).(qualityMeasure)]; 
                qm_simulated = (qm_simulated - qm_nn_simulated) ./ abs(qm_nn_simulated);
                qm_nn_real = [srResults_real([srResults_real(:).binningFactor] == binningFactors(binningFactorIdx) ...
                    &  strcmp('nn', {srResults_real(:).srMethod}) > 0).(qualityMeasure)]; 
                qm_real = (qm_real - qm_nn_real) ./ abs(qm_nn_real);
            end
            
            qm_simulated_mean(srMethodIdx) = mean(qm_simulated);
            qm_real_mean(srMethodIdx) = mean(qm_real);
            
            % Plot quality measure for current SR method.
            facecolor = getFaceColorForSRMethod(srMethods{srMethodIdx});
            plot(qm_simulated_mean(srMethodIdx), qm_real_mean(srMethodIdx), 'o', 'Color', facecolor, 'MarkerFaceColor', facecolor, 'MarkerSize', 6);
            
            % Add text label.
            textLabel = sprintf('%s', upper(srMethods{srMethodIdx}));
            text(qm_simulated_mean(srMethodIdx), qm_real_mean(srMethodIdx), textLabel, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
            hold on;  
        end
        
        spearman(binningFactorIdx) = corr(qm_simulated_mean', qm_real_mean', 'type', 'spearman');
        if normalized
            fprintf('Spearman rank correlation normalized %s (%ix magnification): %.3f\n', upper(qualityMeasure), binningFactors(binningFactorIdx), spearman(binningFactorIdx))
        else
            fprintf('Spearman rank correlation %s (%ix magnification): %.3f\n', upper(qualityMeasure), binningFactors(binningFactorIdx), spearman(binningFactorIdx))
        end
        
        grid on;
        minQ = 0.99*min([qm_simulated_mean qm_real_mean]);
        maxQ = 1.01*max([qm_simulated_mean qm_real_mean]);
        axis([minQ maxQ minQ maxQ]);
        plot([minQ maxQ], [minQ maxQ], 'k--', 'LineWidth', 1.5);
        pbaspect([1 1 1]);
        
        if normalized
            qualityMeasureStr = [qualityMeasure, '_norm'];
            ylabel(sprintf('Norm. %s on real data', upper(qualityMeasure)));
            xlabel(sprintf('Norm. %s on simulated data', upper(qualityMeasure)));
        else
            qualityMeasureStr = qualityMeasure;
            ylabel(sprintf('%s on real data', upper(qualityMeasure)));
            xlabel(sprintf('%s on simulated data', upper(qualityMeasure)));
        end
        
        matlab2tikz([outputDir, '/simulatedToRealDataCorrelation_bin', num2str(binningFactors(binningFactorIdx)), '_', qualityMeasureStr, '.tikz'], ...
            'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
            'extraaxisoptions', ['xlabel near ticks,', 'ylabel near ticks,', 'scaled y ticks=false,', 'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
        
    end