% This script plots the Kendall coefficients of agreement at different
% motion types and binning factors based on the image pairs included in the
% human observer study.
function plotCoefficientOfAgreement(resultDir, outputDir)
    
    % Get precomputed coefficients.
    load([resultDir, '/observerStudy/coefficientsOfAgreement.mat']);
    
    % Plot Kendall coefficients of agreement for different binning factors.
    figure;
    bar_handle = bar(binningFactor, kendall);
    faceColor = autumn(4);
    for k = 1:length(bar_handle)
        set(bar_handle(k), 'FaceColor', faceColor(k,:));
    end
    grid on;
    ylabel('Coefficient of agreement');
    xticklabels({'2x', '3x', '4x'});
    ylim([0 0.5]);
    legend('Global motion', 'Mixed motion', 'Local motion', 'Photometric', ...
        'Location', 'NorthWest');
    
    % Save to TikZ.
    matlab2tikz([outputDir, '/', 'kendallCoefficientOfAgreement.tikz'], ...
        'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
        'extraaxisoptions', ['xlabel near ticks,', ...
        'ylabel near ticks,', ...
        'scaled y ticks=false,', ...
        'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);