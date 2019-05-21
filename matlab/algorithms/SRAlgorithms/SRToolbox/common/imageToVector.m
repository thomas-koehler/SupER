function Ivec = imageToVector(I)
%IMAGETOVECTOR Reshape image to parameter vector.
%   IMAGETOVECTOR linearizes an image from a 2-D array into a parameter
%   vector for further processing in super-resolution.
%
%   J = IMAGETOVECTOR(I) linearizes image I into parameter vector J.
%
%   see also: vectorToImage

    if ismatrix(I)
        Ivec = I';
        Ivec = Ivec(:);
    else
        if ndims(I) > 3
            error('Operation implemented for single 2-D images or sequences of 2-D images');
        end
        
        Ivec = [];
        for k = 1:size(I, 3)
            Ivec = [Ivec; imageToVector(I(:,:,k))]; %#ok<*AGROW>
        end
    end
    