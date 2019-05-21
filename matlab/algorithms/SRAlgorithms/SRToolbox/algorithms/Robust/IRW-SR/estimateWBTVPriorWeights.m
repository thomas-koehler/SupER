function wfun = estimateWBTVPriorWeights

    wfun.function = @WBTVPriorWeightsWeightingFunction;
    wfun.parameters = {0.5, ... % Sparsity parameter
                       2};      % Tuning constant 
    
function [weights, scaleParameter] = WBTVPriorWeightsWeightingFunction(z, weights, sparsityParam, tuningConstant)

    if nargin < 3
        % Use default value p = 0.5 for the sparsity parameter.
        sparsityParam = 0.5;
    end
    if nargin < 4
        tuningConstant = 2;
    end
    
    % Adaptive estimation of the scale parameter.
    scaleParameter = getAdaptiveScaleParameter(z, weights);
    
    % Estimation of the weights based on pre-selected scale parameter.
    weights = (sparsityParam * (tuningConstant*scaleParameter)^(1-sparsityParam)) ./ (abs(z).^(1-sparsityParam));
    weights(abs(z) <= (tuningConstant*scaleParameter)) = 1;
    
function scaleParameter = getAdaptiveScaleParameter(z, weights)

    scaleParameter = weightedMedian( abs(z - weightedMedian(z, weights)), weights );



