function [W, LRImages] = composeSREquationSystem(imSeq, model)
%COMPOSESREQUATIONSYSTEM Compose equation system for super-resolution.
%   COMPOSESREQUATIONSYSTEM combines all input image to a linearized vector
%   and determines system matrix for all frames.
%   
%   see also: composeSystemMatrix

    % Initialize total system matrix.
    numLRPixel = numel(imSeq(:,:,1));
    numHRPixel = round(model.magFactor^2 * numLRPixel);
    numFrames = size(imSeq, 3);
    W = spalloc(numLRPixel*numFrames, numHRPixel, 15*numLRPixel*numFrames);
    % Initialize vector with LR images.
    LRImages = zeros(numLRPixel*numFrames, 1);
    
    % Calculate system matrix for all frames.
    for k = 1:numFrames
        
        startRow = numLRPixel*(k - 1) + 1;
        endRow = startRow + numLRPixel - 1;
        
        % New system matrix entry.
        W(startRow:endRow, :) = composeSystemMatrix(size(imSeq(:,:,k)), model.magFactor, model.psfWidth, model.motionParams{k});
        
        % Stack input LR images together.
        LRImages(startRow:endRow) = imageToVector(imSeq(:,:,k));
        
    end