function  outputData = depatchify(patchData, DParam)
% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
% patchify
%
% creates image from patches
%
% DParam:     training parameters
%
%
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         07/21/2015
%
%
% *************************************************************************
USE_PADDING = 1; %make it divisible by "stride" by extending the image

bordercropping = 0;
overlap = DParam.patchSize - DParam.stride;
offset = (DParam.patchSize - DParam.outputPatchSize)/2; % because we only have center part

outputData = zeros([DParam.inputImgSize(2),DParam.inputImgSize(1)]);
mask = zeros([DParam.inputImgSize(2),DParam.inputImgSize(1)]);

if USE_PADDING == 1
    paddingSize = mod(DParam.stride-(DParam.inputImgSize - DParam.patchSize),DParam.stride);    
    [ xPos, yPos ] = getPatchPos( [DParam.inputImgSize(2)+paddingSize(2),DParam.inputImgSize(1)+paddingSize(1)],DParam.patchSize,overlap,bordercropping);
else
    [ xPos, yPos ] = getPatchPos( [DParam.inputImgSize(2),DParam.inputImgSize(1)],DParam.patchSize,overlap,bordercropping);
end
xPos = xPos + offset;
yPos = yPos + offset;

if size(patchData,4) ~= length(xPos)
    error('Error the number of patches is not consistent with the image size / patch size / overlap configuration')
end


if DParam.zeropadding==1
    offset = DParam.outputPatchSize-1;
    for i = 1:size(patchData,4)

        offsety = min(offset,DParam.inputImgSize(2)-yPos(i));
        offsetx = min(offset,DParam.inputImgSize(1)-xPos(i));
        patchStartIdx = (DParam.patchSize-DParam.outputPatchSize)/2 + 1;
        %if offset~=offsetx || offsety ~=offset
        %   display('error') 
        %end

        
    %    outputData(yPos(i):yPos(i)+DParam.outputPatchSize-1,xPos(i):xPos(i)+DParam.outputPatchSize-1,:) = patchData(:,:,:,i);
    %    outputData(yPos(i):yPos(i)+DParam.outputPatchSize-1,xPos(i):xPos(i)+DParam.outputPatchSize-1,:) = patchData(13:24,13:24,:,i);
        outputData(yPos(i):yPos(i)+offsety,xPos(i):xPos(i)+offsetx,:) = patchData(patchStartIdx:patchStartIdx+offsety,patchStartIdx:patchStartIdx+offsetx,:,i);
        mask(yPos(i):yPos(i)+offsety,xPos(i):xPos(i)+offsetx) = mask(yPos(i):yPos(i)+offsety,xPos(i):xPos(i)+offsetx) + 1;
    end
else 
    for i = 1:size(patchData,4)
        outputData(yPos(i):yPos(i)+DParam.outputPatchSize-1,xPos(i):xPos(i)+DParam.outputPatchSize-1,:) = patchData(:,:,:,i);
        mask(yPos(i):yPos(i)+DParam.outputPatchSize-1,xPos(i):xPos(i)+DParam.outputPatchSize-1) = mask(yPos(i):yPos(i)+DParam.outputPatchSize-1,xPos(i):xPos(i)+DParam.outputPatchSize-1) + 1;
    end
end

mask(mask==0) = 1; %avoid division by zero
outputData = outputData./mask;

end