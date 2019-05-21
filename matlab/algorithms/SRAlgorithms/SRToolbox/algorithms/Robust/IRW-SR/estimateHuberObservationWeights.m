function wfun = estimateHuberObservationWeights
    
    wfun.function = @huberWeightingFunction;
    wfun.parameters = {0.02, ...    % Bias detection threshold
                       2};          % Tuning contant
    
function [weights, scaleParameter] = huberWeightingFunction(r, weights, rMax, tuningConstant)
    
    if nargin < 3
        rMax = 0.02;
    end
    if nargin < 4
        tuningConstant = 2;
    end
    
    % Determine frame-wise confidence (bias detection).
    weightsVec = [];
    rVec = [];
    for k = 1:length(r)   
        rVec = [rVec; r{k}];
        if abs( median(r{k}) ) < rMax
            weightsBias(k) = 1;
        else
            weightsBias(k) = 0;
        end   
        weightsVec = [weightsVec; weights{k} .* weightsBias(k)];
    end
    
    % Use adaptive scale parameter estimation.
    scaleParameter = getAdaptiveScaleParameter(rVec(weightsVec > 0), weightsVec(weightsVec > 0));
    
    % Determine pixel-wise confidence weights.
    for k = 1:length(r)
        % Estimate local confidence weights for current frame.
        weightsLocal = 1 ./ abs(r{k});
        weightsLocal(abs(r{k}) < tuningConstant*scaleParameter) = 1 / (tuningConstant*scaleParameter);
        weightsLocal = tuningConstant*scaleParameter * weightsLocal;

        % Assemble confidence weights from bias (frame-wise) weights and
        % local (pixel-wise) weights.
        weights{k} = weightsBias(k) .* weightsLocal;    
    end
    
function scaleParameter = getAdaptiveScaleParameter (r, weights)

    scaleParameter = 1.4826 * weightedMedian( abs(r(weights > 0) - weightedMedian(r(weights > 0), weights(weights > 0))), weights(weights > 0) );

    