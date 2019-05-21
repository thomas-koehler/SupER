function phometricParams = SRPhotometricParams(numFrames)
%SRPHOTOMETRICPARAMS Photometric parameters used for super-resolution.

    % The multiplicative part of the photometric model.
    % Default: Affine model with multiplicative factor '1'.
    phometricParams.mult = ones(numFrames, 1);
    
    % The additive part of the photometric model.
    % Default: Affine model with additive factor '0'.
    phometricParams.add = zeros(numFrames, 1);