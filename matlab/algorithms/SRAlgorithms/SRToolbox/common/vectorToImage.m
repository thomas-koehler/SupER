function I = vectorToImage(Ivec, imageDim)
%VECTORTOIMAGE Reshape parameter vector to image
%   VECTORTOIMAGE reshapes a given parameter vector into a 2-D array that
%   represents an image.
%
%   J = VECTORTOIMAGE(I, DIM) reshapes vector I into an image J of
%   dimension DIM.
%
%   see also: imageToVector

    I = reshape(Ivec, imageDim(2), imageDim(1));
    I = I';
    