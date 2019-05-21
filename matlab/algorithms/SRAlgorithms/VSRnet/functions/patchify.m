function  patchData = patchify(input_data, DParam)
% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
% patchify
%
% create patches from image for feed forward process
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

if USE_PADDING == 1
    paddingSize = mod(DParam.stride-(DParam.inputImgSize - DParam.patchSize),DParam.stride);
    for i = 1:paddingSize(1)
        input_data(:,end+1,:) = input_data(:,end,:);
    end
    for i = 1:paddingSize(2)
        input_data(end+1,:,:) = input_data(end,:,:);       
    end
    DParam.inputImgSize = DParam.inputImgSize + paddingSize;
    [ xPos, yPos ] = getPatchPos( [DParam.inputImgSize(2)+paddingSize(2),DParam.inputImgSize(1)+paddingSize(1)],DParam.patchSize,overlap,bordercropping);
    patchData = getPatches(input_data,DParam.patchSize,xPos,yPos,false,false);
else
    [ xPos, yPos ] = getPatchPos( [DParam.inputImgSize(2),DParam.inputImgSize(1)],DParam.patchSize,overlap,bordercropping);
    patchData = getPatches(input_data,DParam.patchSize,xPos,yPos,false,false);
end

end
