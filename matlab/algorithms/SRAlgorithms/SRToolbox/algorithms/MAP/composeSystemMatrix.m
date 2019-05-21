function W = composeSystemMatrix(imsize, magFactor, psfWidth, motionParams)
% COMPOSESYSTEMMATRIX Compose generative image model system matrix
%   COMPOSESYSTEMMATRIX composes the system matrix for given model
%   parameters.
%   
%   see also: composeSREquationSystem

    % Create W' using MEX implementation.
    W = composeSystemMatrix_mex(imsize, magFactor, psfWidth, motionParams);
    % Transpose the result to obtain W'.
    W = W';
    
    % Normalize the row sums to one.
    W = spdiags( sum(abs(W),2) + eps, 0, size(W,1), size(W,1) ) \ W;