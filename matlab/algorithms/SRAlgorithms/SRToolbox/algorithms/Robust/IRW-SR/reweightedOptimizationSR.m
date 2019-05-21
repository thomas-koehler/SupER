function [SR, model, report] = reweightedOptimizationSR(LRImages, model, optimParams, varargin)

    if nargin < 3
        % Get default optimization parameters.
        optimParams = getReweightedOptimizationParams;
    end
    
    if nargin > 3
        % Use ground truth image provided by the user for synthetic data
        % experiments.
        groundTruth = varargin{1};
    else
        % No ground truth available.
        groundTruth = [];
    end
    
    if nargout > 2
        % Setup the report structure.
        report.SR = {[]};
        report.sigmaNoise = [];
        report.sigmaPrior = [];
        report.regularizationWeight = [];
        report.valError = {[]};
        report.trainError = {[]};
        report.numFunEvals = 0;
        report.observationWeights = {};
        report.priorWeights = {};
    end
    
    %********** Initialization
    % Setup the coarse-to-fine optimization parameters.
    if ~isempty(optimParams.numCoarseToFineLevels)
        % Get user-defined number of coarse-to-fine levels to build the
        % image pyramid.
        numCoarseToFineLevels = optimParams.numCoarseToFineLevels;
        coarseToFineScaleFactors = max([1 (model.magFactor - numCoarseToFineLevels + 1)]) : model.magFactor;
    else
        % Use default settings for coarse-to-fine optimization. Build image
        % pyramid with integer scales between 1 and the desired
        % magnification factor.
        coarseToFineScaleFactors = min([1 model.magFactor]) : model.magFactor;
    end
    if isempty(model.SR)
        % Initialize super-resolved image by the temporal median of the 
        % motion-compensated low-resolution frames.
        SR = imageToVector( imresize(medfilttemp(LRImages, model.motionParams), coarseToFineScaleFactors(1)) );
    else
        % Use the user-defined initial guess. This image needs to be
        % resized to the coarsest level of the image pyramid.
        SR = imageToVector( imresize(model.SR, coarseToFineScaleFactors(1) * size(LRImages(:,:,1))) );
    end   
    % Initialize the confidence weights of the observation model.
    for frameIdx = 1:size(LRImages, 3)
        % Use uniform weights as initial guess.
        observationWeights{frameIdx} = ones(numel(LRImages(:,:,frameIdx)), 1);
    end
    if isempty(model.confidence)
        model.confidence = observationWeights;
    end
    observationWeightsStatic = model.confidence;
    
    % Iterations for cross validation based hyperparameter selection.
    maxCVIter = optimParams.maxCVIter;
    
    % Decide if the regularization weight should be automatically adjusted
    % per iteration.
    if isempty(model.imagePrior.weight)
        % No user-defined parameter available. Adjust the weight at each
        % iteration.
        useFixedRegularizationWeight = false;
    else
        % Use the user-defined regularization weight.
        useFixedRegularizationWeight = true;
    end
    
    % Main optimization loop of iteratively re-weighted minimization.
    for iter = 1 : optimParams.maxMMIter
            
        %********** Extract current level from image pyramid.
        if iter <= length(coarseToFineScaleFactors)            
            % Assemble the system matrices for this level of the image
            % pyramid.
            model.magFactor = coarseToFineScaleFactors(iter);
            for frameIdx = 1:size(LRImages, 3)
                W{frameIdx} = composeSystemMatrix(size(LRImages(:,:,frameIdx)), model.magFactor, model.psfWidth, model.motionParams{frameIdx});
                Wt{frameIdx} = W{frameIdx}';
            end
            
            % Propagate the estimate to this level of the image pyramid.
            if iter > 1
                SR = imresize(vectorToImage(SR, coarseToFineScaleFactors(iter-1) * size(LRImages(:,:,1))), coarseToFineScaleFactors(iter)*size(LRImages(:,:,1)));
                SR = imageToVector(SR);
            end      
        end
        % else: we have already reached the desired magnification level.
        
        %********** Update the observation confidence weights.
        sigmaNoise = 0;
        if ~isempty(optimParams.observationWeightingFunction)
            for frameIdx = 1:size(LRImages, 3)
                % Compute the residual error.
                y{frameIdx} = imageToVector(LRImages(:,:,frameIdx));
                if ~isempty(model.photometricParams)
                    if ~isvector(model.photometricParams.mult)
                        residualError{frameIdx} = getResidualForSingleFrame(SR, y{frameIdx}, W{frameIdx}, model.photometricParams.mult(:,:,frameIdx), model.photometricParams.add(:,:,frameIdx));
                    else
                        residualError{frameIdx} = getResidualForSingleFrame(SR, y{frameIdx}, W{frameIdx}, model.photometricParams.mult(frameIdx), model.photometricParams.add(frameIdx));
                    end
                else
                    residualError{frameIdx} = getResidualForSingleFrame(SR, y{frameIdx}, W{frameIdx});
                end
            end
            [observationWeights, sigmaNoise] = optimParams.observationWeightingFunction.function(residualError, model.confidence, optimParams.observationWeightingFunction.parameters{1:end});
            
            % Combine the dynamic observation weights with static,
            % user-defined confidence weights.
            for frameIdx = 1:size(LRImages, 3)
                model.confidence{frameIdx} = observationWeightsStatic{frameIdx} .* observationWeights{frameIdx};
            end
            
        % else: use uniform weights if no weighting function provided
        end
        
        %********** Update the image prior confidence weights.
        sigmaPrior = 0;
        if ~isempty(optimParams.priorWeightingFunction)
            % Apply sparsity transform to the current estimate of the
            % high-resolution image according to the image prior.
            model.imagePrior.parameters{1} = model.magFactor * size(LRImages(:,:,1));
            [~, transformedImage] =  model.imagePrior.function(SR, model.imagePrior.parameters{1:end-1});
            % Filtering of the sparsity transformed image.
            transformedImageFiltered = [];
            if iscell(transformedImage)
                for l = 1:size(transformedImage,1)
                    for m = 1:size(transformedImage,2)
                        if ~isempty(transformedImage{l,m})
                            z = vectorToImage( transformedImage{l,m}, model.magFactor * size(LRImages(:,:,1)));
                            transformedImageFiltered = [transformedImageFiltered; imageToVector( medfilt2(z, [3 3]) )];
                        end
                    end
                end
            else
                transformedImageFiltered = imageToVector( medfilt2(transformedImage, [3 3]) );
            end
            if ~exist('priorWeights', 'var')
                % Initialize weights at the first iteration.
                priorWeights = ones(size(transformedImageFiltered));
            end
            if numel(priorWeights) ~= numel(transformedImageFiltered)
                % Propagate the weights from the previous level in
                % coarse-to-fine optimization to the current level.
                priorWeights = imresize(priorWeights, size(transformedImageFiltered));
            end
            [priorWeights, sigmaPrior] = optimParams.priorWeightingFunction.function(transformedImageFiltered, priorWeights, optimParams.priorWeightingFunction.parameters{1:end});
        else
            % Use uniform weights if no weighting function provided.
            priorWeights = 1;
        end
        model.imagePrior.parameters{end} = priorWeights;

        %********** Hyperparameter selection
        if maxCVIter > 1 && ~useFixedRegularizationWeight
            % Automatic hyperparameter selection using cross validation.
            [model.imagePrior.weight, SR_best] = selectRegularizationWeight;
            % Update number of cross validation iterators.
            maxCVIter = max([round( 0.5 * maxCVIter ) 1]); 
        else
            % No automatic hyperparameter selection required.
            SR_best = SR;
        end
         
        %********** Update estimate for the high-resolution image.
        SR_old = SR;
        [SR, numFunEvals] = updateHighResolutionImage(SR_best, model, y, W, Wt);
        
        %********** Check for convergence.
        if isConverged(SR, SR_old) && (iter > length(coarseToFineScaleFactors))
            % Convergence tolerance reached.
            SR = vectorToImage(SR, model.magFactor * size(LRImages(:,:,1)));
            return;
        end
        
        if nargout > 2
            % Log results for current iteration.
            report.SR{iter} = vectorToImage(SR, model.magFactor * size(LRImages(:,:,1)));
            report.numFunEvals = report.numFunEvals + numFunEvals;
            report.sigmaNoise(iter) = sigmaNoise;
            report.sigmaPrior(iter) = sigmaPrior;
            report.regularizationWeight(iter) = model.imagePrior.weight;
            report.observationWeights = cat(1, report.observationWeights, model.confidence);
            report.priorWeights = cat(1, report.priorWeights, priorWeights);
            if ~isempty(groundTruth)
                % Measure PSNR and SSIM for the given ground truth image.
                report.psnr(iter) = psnr(imresize(vectorToImage(SR, model.magFactor * size(LRImages(:,:,1))), size(groundTruth)), groundTruth);
                report.ssim(iter) = ssim(imresize(vectorToImage(SR, model.magFactor * size(LRImages(:,:,1))), size(groundTruth)), groundTruth);
            end
        end
        
    end
    
    SR = vectorToImage(SR, model.magFactor * size(LRImages(:,:,1)));
    
    function [SR, numIters] = updateHighResolutionImage(SR, model, y, W, Wt)
        
        % Setup parameters for SCG optimization.
        scgOptions = zeros(1,18);
        scgOptions(2) = optimParams.terminationTol;
        scgOptions(3) = optimParams.terminationTol;
        scgOptions(10) = optimParams.maxSCGIter;
        scgOptions(14) = optimParams.maxSCGIter;
        
        % Perform SCG iterations to update the current estimate of the
        % high-resolution image.
        if iscolumn(SR)
            SR = SR';
        end
        [SR, ~, flog] = scg(@imageObjectiveFunc, SR, scgOptions, @imageObjectiveFunc_grad, model, y, W, Wt);
        numIters = length(flog);
        SR = SR';
        
    end

    function [bestLambda, SR_best] = selectRegularizationWeight
        
        % Split the set of given observations into training and validation
        % subset.
        for k = 1:size(LRImages, 3)
            fractionCvTrainingObservations = optimParams.fractionCVTrainingObservations;
            trainObservations{k} = 1 - (randn(size(y{k})) > fractionCvTrainingObservations);  %#ok<*AGROW>
            y_train{k}  = y{k}(trainObservations{k} == 1);
            y_val{k}    = y{k}(trainObservations{k} == 0);
            W_train{k}  = W{k}(trainObservations{k} == 1,:);
            Wt_train{k} = W_train{k}';
            W_val{k}    = W{k}(trainObservations{k} == 0,:);
            if ~isempty(model.photometricParams)
                if isvector(model.photometricParams.mult)
                    gamma_m_train{k}    = model.photometricParams.mult(k);
                    gamma_m_val{k}      = model.photometricParams.mult(k);
                    gamma_a_train{k}    = model.photometricParams.add(k);
                    gamma_a_val{k}      = model.photometricParams.add(k);
                else
                    gamma_m = model.photometricParams.mult(:,:,k);
                    gamma_m_train{k}    = gamma_m(trainObservations{k} == 1);
                    gamma_m_val{k}      = gamma_m(trainObservations{k} == 0);
                    gamma_a             = model.photometricParams.add(:,:,k);
                    gamma_a_train{k}    = gamma_a(trainObservations{k} == 1);
                    gamma_a_val{k}      = gamma_a(trainObservations{k} == 0);
                end
            else
                gamma_m_train{k}    = [];
                gamma_m_val{k}      = [];
                gamma_a_train{k}    = [];
                gamma_a_val{k}      = [];
            end
        end
        
        % Setup the model structure for the training subset.
        parameterTrainingModel = model;
        for k = 1:size(LRImages, 3)
            observationConfidenceWeights = model.confidence{k};
            parameterTrainingModel.confidence{k} = observationConfidenceWeights(trainObservations{k} == 1);
        end
        
        % Define search range for adaptive grid search.
        if ~isempty(model.imagePrior.weight)
            % Refine the search range from the previous iteration.
            lambdaSearchRange = logspace(log10(model.imagePrior.weight) - 1/iter, log10(model.imagePrior.weight) + 1/iter, maxCVIter);
        else
            % Set search range used for initialization.
            lambdaSearchRange = logspace(optimParams.hyperparameterCVSearchRange(1), optimParams.hyperparameterCVSearchRange(2), maxCVIter);
            bestLambda = median(lambdaSearchRange);
        end
        
        % Perform adaptive grid search over the selected search range.
        SR_best = SR;
        minValError = Inf;
        if exist('report', 'var')
            report.valError{iter} = [];
            report.trainError{iter} = [];
        end
        for lambda = lambdaSearchRange
                       
            % Estimate super-resolved image from the training set.
            parameterTrainingModel.imagePrior.weight = lambda;
            [SR_train, numFunEvals] = updateHighResolutionImage(SR, parameterTrainingModel, y_train, W_train, Wt_train);
            
            % Determine errors on the training and the validation subset.
            valError = 0;
            trainError = 0;
            for k = 1:size(LRImages, 3)
                observationConfidenceWeights = model.confidence{k};
                % Error on the validation subset.
                rk_val = getResidualForSingleFrame(SR_train, y_val{k}, W_val{k}, gamma_m_val{k}, gamma_a_val{k});
                valError = valError + sum( observationConfidenceWeights(trainObservations{k} == 0) .* (rk_val.^2) );
                % Error on the training subset.
                rk_train = getResidualForSingleFrame(SR_train, y_train{k}, W_train{k}, gamma_m_train{k}, gamma_a_train{k});
                trainError = trainError + sum( observationConfidenceWeights(trainObservations{k} == 1) .* (rk_train.^2) );
            end
            if valError < minValError
                % Found optimal regularization weight.
                bestLambda = lambda;
                minValError = valError;
                SR_best = SR_train;
            end
            
            if exist('report', 'var')
                report.numFunEvals = report.numFunEvals + length(numFunEvals);
                % Save errors on training and validation sets.
                report.valError{iter} = cat(1, report.valError{iter}, valError);
                report.trainError{iter} = cat(1, report.trainError{iter}, trainError);
            end
        end
        
    end

    function converged = isConverged(SR, SR_old)        
        converged = (max(abs(SR_old - SR)) < optimParams.terminationTol);
    end
    
end
    
function f = imageObjectiveFunc(SR, model, y, W, ~)
    
    if ~iscolumn(SR)
        % Reshape to column vector. 
        SR = SR';
    end
    
    % Evaluate the data fidelity term.
    dataTerm = 0;
    for k = 1:length(y)
        if ~isempty(model.photometricParams)
            if isvector(model.photometricParams.mult)
                rk = getResidualForSingleFrame(SR, y{k}, W{k}, model.photometricParams.mult(k), model.photometricParams.add(k));
            else
                rk = getResidualForSingleFrame(SR, y{k}, W{k}, model.photometricParams.mult(:,:,k), model.photometricParams.add(:,:,k));
            end
        else
            rk = getResidualForSingleFrame(SR, y{k}, W{k});
        end
        dataTerm = dataTerm + sum( model.confidence{k} .* (rk.^2) );
    end
    
    % Evaluate image prior for regularization the super-resolved estimate.
    priorTerm = model.imagePrior.function(SR, model.imagePrior.parameters{1:end});
        
    % Calculate objective function.
    f = dataTerm + model.imagePrior.weight * priorTerm;
    
end
                
function grad = imageObjectiveFunc_grad(SR, model, y, W, Wt)
    
    if ~iscolumn(SR)
        % Reshape to column vector. 
        SR = SR';
    end
    
    % Calculate gradient of the data fidelity term w.r.t. the
    % super-resolved image.
    dataTerm_grad = 0;
    for k = 1:length(y)
        if ~isempty(model.photometricParams)
            if isvector(model.photometricParams.mult)
                rk = getResidualForSingleFrame(SR, y{k}, W{k}, model.photometricParams.mult(k), model.photometricParams.add(k));
            else
                rk = getResidualForSingleFrame(SR, y{k}, W{k}, model.photometricParams.mult(:,:,k), model.photometricParams.add(:,:,k));
            end
        else
            rk = getResidualForSingleFrame(SR, y{k}, W{k});
        end
        dataTerm_grad = dataTerm_grad - 2*Wt{k} * ( model.confidence{k} .* rk ); 
    end
    
    % Calculate gradient of the regularization term w.r.t. the 
    % super-resolved image.
    priorTerm_grad = model.imagePrior.gradient(SR, model.imagePrior.parameters{1:end});
    
    % Sum up to total gradient
    grad = dataTerm_grad + model.imagePrior.weight * priorTerm_grad;
    grad = grad';
    
end

function r = getResidualForSingleFrame(x, y, W, gamma_m, gamma_a)
    
    if nargin < 4 || isempty(gamma_m)
        gamma_m = 1;
    end
    if nargin < 5 || isempty(gamma_a)
        gamma_a = 0;
    end
    r = (y - (gamma_m .* (W*x) + gamma_a));
    
end
    
    