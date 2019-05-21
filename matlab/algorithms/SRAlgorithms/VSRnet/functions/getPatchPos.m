function [ xPos, yPos ] = getPatchPos( imgSize,patchSize,overlap,border,randOffset)
% *************************************************************************
% Superresolution with Dictionary Technique
% getPatches  
%
% Description:
% returns the coordinates for the upper left corner of patches from an 
% image.
% 
% parameter: 
% border:    border around image, where no patches are taken
% overlap:   defines the patch overlap in pixels
% randOffset: adds a random offset to the patches
% 
% Version 1.1
%
% Created by:   Armin Kappeler
% Date:         03/04/2013
%
% Modifications:
% 03/21/2013    Armin Kappeler   no image needed anymore
% 
% *************************************************************************
if nargin < 5
   randOffset = 0; 
end

if overlap >= patchSize
    error('Overlap too big')
end

% define border
minX = border+1;
maxX = imgSize(2) - border - patchSize + 1;
minY = border+1;
maxY = imgSize(1) - border - patchSize + 1;

%[yPos, xPos] = meshgrid(minY:patchSize-overlap:maxY,minX:patchSize-overlap:maxX);
[xPos, yPos] = meshgrid(minX:patchSize-overlap:maxX,minY:patchSize-overlap:maxY);

xPos = xPos(:);
yPos = yPos(:);

% add random offset
if randOffset
    xResidual = maxX - max(xPos);    
    if (xResidual>0)
        xPos = xPos + randi(xResidual)-1;
    end
    
    yResidual = maxY - max(yPos);    
    if (yResidual>0)
        yPos = yPos + randi(yResidual);
    end
end
    





