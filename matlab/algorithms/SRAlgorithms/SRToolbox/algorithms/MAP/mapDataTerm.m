function f = mapDataTerm(SR, model, LR, W)

    % Compute residual error for super-resolved estimate.
    r = getResidual(SR, LR, W, model.photometricParams);
    % Get confidence map associated with the residual error
    confidence = model.confidence;
    if isempty(confidence)
        % Default: equal confidence for each pixel
        confidence = ones(size(LR));
    end
    if ~isvector(confidence)
        confidence = imageToVector(confidence);
    end
    
    % Calculate the data fidelity measure
    if strcmp(model.errorModel, 'l2NormErrorModel')
        % L2 norm error model (least-squares optimization)
        f = sum(confidence .* (r.^2));
    elseif strcmp(model.errorModel, 'l1NormErrorModel')
        % L1 norm error model (least absolute devation optimization)
        f = sum(confidence .* abs(r));
    else
        [f, g] = model.errorModel(r);
        f = sum(confidence .* f);
    end