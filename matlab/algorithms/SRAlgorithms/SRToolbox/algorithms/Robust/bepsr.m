function [SR, report] = bepsr(LRImages, model, varargin)
  
    if nargin > 2
        solverParams = varargin{end};
    else
        % Use default solver parameters
        solverParams = SRSolverParams;
    end
    
    % Assemble equation system to be solved consisting of low-resolution
    % observations and the system matrix.
    lrDim = size(LRImages(:,:,1));
    if solverParams.verbose
        disp('Assemble equation system (system matrix)...');
    end
    [W, Y] = composeSREquationSystem(LRImages, model);
        
    if isempty(model.SR)
        % Compute initial guess for the super-resolved image. We use the
        % "average image" estimated from the system matrix and photometric
        % parameters (if available).
        if solverParams.verbose
            disp('Compute average image used as initial guess...');
        end
        SR = getInitialSRImage(W, Y, model.photometricParams);
    else
        % Use initial guess provided by the user and reshape 2-D image into
        % parameter vector.
        SR = imageToVector(model.SR);
    end
        
    scgOptions = setupSCGOptions(solverParams);
    if solverParams.verbose
        disp('Minimize objective function...');
    end
    
    % Precompute the adaptive M-estimator scale parameters.
    a = computeAdaptiveScaleParameters(W, SR, LRImages);
    
    % Perform iterative minimization using the precomputed parameters.
    [SR, ~, flog, ~, ~] = scg(@mapfunc, SR', scgOptions, @mapfunc_grad, model, LRImages, W, W', a);
    if nargout > 1
        % Report the number of iterations / function evaluations.
        report.numFunEvals = length(flog);
    end
    
    % Reshape parameter vector to a 2D image.
    SR = vectorToImage(SR, model.magFactor * lrDim);
    if solverParams.verbose
        disp('DONE!');
    end
    
function scgOptions = setupSCGOptions(solverParams)

    scgOptions = zeros(1,18); 
    scgOptions(1) = 0;        
    scgOptions(2) = solverParams.tolX;   
    scgOptions(3) = solverParams.tolF;
    scgOptions(9) = solverParams.gradCheck;
    scgOptions(10) = solverParams.maxFunEvals;     
    scgOptions(14) = solverParams.maxIter;

function a = computeAdaptiveScaleParameters(W, SR, LRImages)

    numFrames = size(LRImages, 3);
    e = zeros(1, numFrames);
    % Compute the mean absolute residual error for all frames.
    for k = 1:size(LRImages, 3)
        % Get the k-th low-resolution frame
        yk = imageToVector(LRImages(:,:,k));
        numLRPixel = length(yk);
        startRow = numLRPixel*(k - 1) + 1;
        endRow = startRow + numLRPixel - 1;
        % Get the system matrix associated with this frame.
        Wk = W(startRow:endRow, :);
        % Determine the mean absolute error for this frame.
        e(k) = mean( abs(Wk*SR - yk) );   
    end
    
    % Initialize the maximum and the minium of the M-estimator scale
    % parameter assuming that all frames are encoded in the range [0, 1].
    amin = 1e-4;
    amax = max(e);
    % Get minimum and maximum of the absolute residual error.
    emax = max(e);
    emin = min(e);
    
    % Compute the adaptive M-estimator scale parameters for all frames.
    tau = (amax - amin) / (emax^2 - emin^2);
    gamma = (amax * emax^2 - amin * emin^2) / (emax^2 - emin^2);
    a = -tau * e.^2 + gamma;

function f = mapfunc(SR, model, LR, W, Wt, a)
    
    if ~iscolumn(SR)
        % Reshape to column vector. 
        SR = SR';
    end
    
    % Compute objective value associated with the different low-resolution
    % frames.
    fData = zeros(size(length(a)));
    for k = 1:length(a)
        % Get current frame with the associated system matrix.
        numLRPixel = numel(LR(:,:,k));
        startRow = numLRPixel*(k - 1) + 1;
        endRow = startRow + numLRPixel - 1;
        Wk = W(startRow:endRow, :);
        yk = imageToVector(LR(:,:,k));
        
        % Compute the objective value using the precomputed scale
        % parameter.
        fData(k) = sum( adaptiveErrorNorm(Wk*SR - yk, a(k)) );
    end
    
    % Compute the value of the regularization term.
    fReg = model.imagePrior.function(SR, model.imagePrior.parameters{1:end});    
    
    % Compute the overall objective value.
    f = sum(fData) + model.imagePrior.weight * fReg;
                
function grad = mapfunc_grad(SR, model, LR, W, Wt, a)
    
    if ~iscolumn(SR)
        % Reshape to column vector. 
        SR = SR';
    end
    
    % Calculate gradient of the data fidelity term w.r.t. the
    % super-resolved image.
    fData_grad = 0;
    for k = 1:length(a)
        % Get current frame with the associated system matrix.
        numLRPixel = numel(LR(:,:,k));
        startRow = numLRPixel*(k - 1) + 1;
        endRow = startRow + numLRPixel - 1;
        Wk = W(startRow:endRow, :);
        Wtk = Wt(:, startRow:endRow);
        yk = imageToVector(LR(:,:,k));
        
        % Compute gradient of the adpative error norm using the precomputed
        % scale parameter.
        [~, gk] = adaptiveErrorNorm(Wk*SR - yk, a(k));
        
        % Compute the overall gradient associated with this frame.
        fData_grad = fData_grad + Wtk * gk;
    end
    
    % Compute the gradient of the regularization term.
    fReg_grad = model.imagePrior.gradient(SR, model.imagePrior.parameters{1:end});
    
    % Sum up to total gradient of the objective function.
    grad = fData_grad + model.imagePrior.weight * fReg_grad;
    grad = grad';
    
function [f, g] = adaptiveErrorNorm(e, a)
    
    % Compute the objective value.
    f = a * sqrt(a^2 + e.^2);
    if nargout > 1
        % Compute the gradient of the function in addition to the objecive
        % value.
        g = (a .* e) ./ sqrt(a.^2 + e.^2);
    end