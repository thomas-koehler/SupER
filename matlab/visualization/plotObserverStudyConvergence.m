% This plots the convergence of the human observer study in terms of the
% Kendall coefficients of agreement versus different numbers of workers and
% error thresholds for the sanity checks.
function plotObserverStudyConvergence(resultDir, outputDir)
    
    % Get precomputed coefficients.
    load([resultDir, '/observerStudy/observerStudyConvergence.mat']);
    
    % Mean and standard deviation of the Kendall coefficient of agreement
    % over the samples of the Monte Carlo simulation.
    kendallMean = mean(kendall, 3);
    kendallStd = std(kendall, [], 3);
    
    % Plot Kendall coefficient of agreement vs. number of workers.
    lineStyle = {'-', '--', '-.', ':'};
    lineColor = {[0 0 1], [1 0 0], [1 0.65 0], [0 1 0]};
    figure;
    for maxSanityCheckFailsIdx = 1:length(maxSanityCheckFails)
        errorbar(numWorkers, kendallMean(maxSanityCheckFailsIdx,:), kendallStd(maxSanityCheckFailsIdx,:), ...
            lineStyle{maxSanityCheckFailsIdx}, 'Color', lineColor{maxSanityCheckFailsIdx}, 'LineWidth', 1.5);
        legendStr{maxSanityCheckFailsIdx} = sprintf('$n_f$ = %s', num2str(maxSanityCheckFails(maxSanityCheckFailsIdx)));
        hold on;
    end
    hold off;
    grid on;
    xlabel('Number of user sessions');
    ylabel('Coefficient of agreement');
    xlim([numWorkers(1) numWorkers(end)]);
    
    % Add legend
    legend(legendStr, 'Location', 'NorthEast', 'Orientation', 'horizontal', 'Interpreter', 'latex');
    
    % Save to TikZ.
    matlab2tikz([outputDir, '/', 'userStudyConvergence.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);