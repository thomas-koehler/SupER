function opts = getReweightedOptimizationParams

    % Maximum number of majorization-minimization (MM) iterations used for
    % iteratively re-weighted minimization (should be between 5 and 15).
    opts.maxMMIter = 10;
    
    % Maximum number of scaled conjugate gradients (SCG) iterations in the
    % inner optimization loop used for image reconstruction (should be
    % between 3 and 10).
    opts.maxSCGIter = 5;
    
    % Maximum number of cross validation (CV) iterations for hyperparameter
    % selection (should be between 10 and 30).
    opts.maxCVIter = 20;
        
    % Fraction of the observations used for the training stage in
    % hyperparameter selection (should be between 0.90 and 0.95).
    opts.fractionCVTrainingObservations = 0.95;
    
    % Initial search range (lower and upper bound) for the regularization 
    % hyperparameter on a logarithmic scale (should be between 10-12 and
    % 10^0).
    opts.hyperparameterCVSearchRange = [-12 0];
    
    % Termination tolerance for max(x(t) - x(t-1)) for the estimate of the
    % high-resolution image over the MM and SCG iterations (should be 
    % approx. 1e-3).
    opts.terminationTol = 1e-3;
        
    % Number of levels used for coarse-to-fine optimization. If empty, the
    % number of levels is set automatically (should be between 2 and 5).
    opts.numCoarseToFineLevels = [];
    
    % The weighting function that is used to determine the observation
    % confidence weights. This function needs to be defined as a struct P 
    % with the following fields:
    %   - P.function is a function handle to weighting function to compute
    %     the confidence weights based on the residual error. The residual
    %     errors for the different frames need to be stored as a cell
    %     array.
    %   - P.parameters are additional parameters that are passed to the
    %     function P.function.
    opts.observationWeightingFunction = estimateHuberObservationWeights;
    
    % The weighting function that is used to determine the adpative prior
    % weights. This function needs to be defined as a struct P with the 
    % following fields:
    %   - P.function is a function handle to weighting function to compute
    %     the prior weights based on a given image in a certain transform
    %     domain.
    %   - P.parameters are additional parameters that are passed to the
    %     function P.function.
    opts.priorWeightingFunction = estimateWBTVPriorWeights;
    