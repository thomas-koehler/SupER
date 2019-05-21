% Plot tradeoff between image quality (in terms of mean BT scores) and
% computation times of the different super-resolution algorithms.
function plotQualityTimeTradeoff(resultDir, outputDir)

    % Load results
    load([resultDir, '/observerStudy/qualityTimeTradeoff.mat']);
     
    srMethods = SRMethods;
    srMethodNames = {srMethods.name};        
    for binningFactorIdx = 1:length(binningFactor)
        
        % Plot BT score vs. computation time for the different algorithms.
        figure;
        for srMethodIdx = 1:size(btScoreMean,1)
            
            if strcmp(srMethodNames{srMethodIdx}, 'nn') || strcmp(srMethodNames{srMethodIdx}, 'bicubic')
                % Do not plot NN and bicubic interpolation.
                continue;
            end

            % Plot point for current SR method.
            if strcmp(srMethods(srMethodIdx).type, 'sisr')
                markerColor = 'b';
                markerStyle = 'bs';
            else
                markerColor = 'r';
                markerStyle = 'ro';
            end
            semilogx(srTimeTotal(srMethodIdx, binningFactorIdx), btScoreMean(srMethodIdx,binningFactorIdx), markerStyle, 'MarkerSize', 6, 'MarkerFaceColor', markerColor);
            
            hold on;
            % Add label to point.
            textLabel = sprintf('%s', upper(srMethodNames{srMethodIdx}));
            text(srTimeTotal(srMethodIdx, binningFactorIdx), btScoreMean(srMethodIdx, binningFactorIdx), textLabel, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
            hold on;

        end
        
        % Format axis limits and labels.
        ylim([-4 2]);
        xlim([1 1e4]);
        xlabel('Computation time [s]');
        ylabel('Mean B-T score');
        grid on;
        
        % Save as TikZ.
        matlab2tikz([outputDir, '/', 'qualityTimeTradeoff_bin', num2str(binningFactor(binningFactorIdx)) ,'.tikz'], ...
            'height', '\figureheight', 'width', '\figurewidth', 'showInfo', false, ...
            'extraaxisoptions', ['xlabel near ticks,', ...
            'ylabel near ticks,', ...
            'scaled y ticks=false,', ...
            'yticklabel style={/pgf/number format/fixed, /pgf/number format/precision=2},']);
    
    end