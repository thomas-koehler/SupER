function r = getResidual(SR, LR, W, photometricParams)
% GETRESIDUAL Get residual error for low-resolution and super-resolved
% data.
%   GETRESIDUAL computes the the residual error caused by a super-resolved
%   image with the associated low-resolution frames and the model
%   parameters (system matrix and photometric parameters).

    if nargin < 4 || isempty(photometricParams)
        r = LR - W*SR;
    else
        numFrames = size(photometricParams.mult, 3);
        numLRPixel = length(LR)/numFrames;
        if isvector(photometricParams.mult(:,:,1))
            bm = zeros(size(LR));
            ba = zeros(size(LR));
            for k = 1:numFrames
                bm( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(photometricParams.mult(k), numLRPixel, 1);
                ba( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(photometricParams.add(k), numLRPixel, 1);
            end
        else
            bm = zeros(size(LR));
            ba = zeros(size(LR));
            for k = 1:numFrames
                bm( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = imageToVector(photometricParams.mult(:,:,k));
                ba( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = imageToVector(photometricParams.add(:,:,k));
            end
        end
        r = LR - bm .* (W*SR) - ba;
    end