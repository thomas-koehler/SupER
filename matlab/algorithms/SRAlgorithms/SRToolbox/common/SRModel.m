function model = SRModel
%SRMODEL Super-resolution model parameter structure.

    % Magnification factor used for super-resolution (default: 2)
    model.magFactor = 2.0;              
    
    % Width of isotropic Gaussian PSF (default: 0.4)
    model.psfWidth = 0.4;           
    
    % Motion parameters used for super-resolution. This can be either a
    % 2-D homography to model parametric motion or displacement vector
    % fields in case of local motion estimation (optical flow).
    %   - 2-D homography:
    %       Motion is given by a cell array of 2-D homographies where the
    %       k-th element models the motion for the k-th low-resolution
    %       frame:
    %           motionParams{1} = [h11 h12 h13; h21 h22 h23; h31 h32 h33]
    %           motionParams{2} = ...
    %   - Displacement fields:
    %       Motion is given by cell array of displacement fields where the
    %       k-th element models the motion for the k-th low-resolution.
    %       A displacement field is given by a structure with matrices to
    %       model displacements in x- and y-direction:
    %           v.vx = [...]    Displacements in x-direction (pixel-wise)
    %           v.vy = [...]    Displacements in y-direction (pixel-wise)
    %           motionParams{1} = v;
    %           motionParams{2} = ...
    model.motionParams = [];        
    
    % Photometric parameters used for super-resolution (optional).
    % see also SRPhotometricParams
    model.photometricParams = [];
    
    % Error (noise) model assumed for the low-resolution observations
    % (optional). Can be either 'l2NormErrorModel' (least square, default) 
    % in case  of Gaussian noise or 'l1NormErrorModel' (least absolute 
    % deviation) in case of Laplacian noise. Additionally, user-defined
    % error models can be specified, e.g. a Lorentzian M-estimator:
    %   sigma = 0.05;
    %   lorentzian = @(r) deal(log(1 + 0.5*(r/sigma).^2), ... Function
    %                          (2*r) ./ (r.^2 + 2*sigma^2));  Gradient
    %   model.errorModel = lorentzian;
    model.errorModel = 'l2NormErrorModel';
    
    % Image prior used for regularization of super-resolved images. 
    % see also SRPrior
    model.imagePrior = [];
    
    % Confidence map for the low-resolution observations (optional). A 3-D
    % array of size M x N x K can be used to weight K low-resolution frames
    % of size M x N pixel-wise.
    model.confidence = [];
    
    % Initial guess for the super-resolved image (optional). This can be
    % used as starting point for numerical optimization algorithms for
    % image reconstruction.
    model.SR = [];