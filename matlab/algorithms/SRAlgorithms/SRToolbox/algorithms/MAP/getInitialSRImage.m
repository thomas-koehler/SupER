function SR = getInitialSRImage(W, LRImages, photoParams)
% GETINITIALSRIMAGE Initial guess for super-resolved image
%   GETINITIALSRIMAGE computes a rough estimate for the super-resolved
%   image from given model parameters.
%
%   X = GETINITIALSRIMAGE(W, Y, PHOTOPARAMS) computes the "average image" X
%   as initial guess based on the system matrix W, the low-resolution data 
%   Y and the photometric parameters PHOTOPARAMS.
%
%   See David P. Capel, Image Mosaicing and Super-resolution, PhD thesis,
%   2001 for details.

    if nargin > 2 && ~isempty(photoParams)
        numFrames = length(photoParams.mult);
        numLRPixel = length(LRImages) / numFrames;
       
        % Compose photometric parameters into additive and multiplicative term.
        bm = zeros(size(LRImages));
        ba = zeros(size(LRImages));
        for k = 1:numFrames
            bm( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(photoParams.mult(k), numLRPixel, 1);
            ba( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(photoParams.add(k), numLRPixel, 1);
        end
        bm_invmat = spdiags(1./bm(:), 0, length(bm), length(bm));
    
        % Compute "average image" from low-resolution observtions, system
        % matrix and phtometric parameters.
        SR =  (W' * bm_invmat * (LRImages - ba .* ones(size(LRImages)))) ./ (sum(W, 1)' + 1e-4);
    else
        % Compute "average image" without photometric parameters
        SR = (W' * LRImages) ./ (sum(W, 1)' + 1e-4);
    end