% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
%
% This function calculates the motion compensated, bicubically upsampled 
% input frames
% 
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% *************************************************************************
function [input_data,idx_gt] = preprocess_frames(im_LR,upscale,MOTIONCOMPENSATION,ADAPTIVEMOTIONCOMPENSATION)

%% parameters
DParam.prescaling = 1;
DParam.upscaleFactor = upscale;
DParam.patchSize = 36;      
DParam.stride = 36;     
framesPerBlock = 5;


if ADAPTIVEMOTIONCOMPENSATION
    MOTIONCOMPENSATION = 1;
    ADAPT_WEIGHT = 8;
else
    ADAPT_WEIGHT = 0;
end

%% initialization
image_dims = [size(im_LR,1) size(im_LR,2)]*DParam.upscaleFactor;
nrFrames = size(im_LR,3);
framesOrder = 1:framesPerBlock;
framesOrder(floor(framesPerBlock/2)+1) = [];
framesOrder = [floor(framesPerBlock/2)+1 framesOrder];

nrSets = nrFrames-framesPerBlock+1;
tmpImgH5 = zeros([image_dims(2) image_dims(1) framesPerBlock+2 nrSets],'single');

%% loop through framesets (one frameset consists of 5 frames)
for i=1:nrSets
    display(['preprocessing frame ' num2str(i) ' of ' num2str(nrSets)])
    tic;
    %% loop through frames
    imgHi_bic_center = [];
    for layer=framesOrder

        %% load image
        fileIdx = i+layer-1;
        imgLo = im_LR(:,:,fileIdx);
        if isinteger(imgLo)
            imgLo = im2double(imgLo);
        end
        
        imgHi_bic = imresize(imgLo,DParam.upscaleFactor,'bicubic');

        %% motion compensation
        if MOTIONCOMPENSATION
            if layer == floor(framesPerBlock/2)+1 %center frame
                imgHi_bic_center = imgHi_bic;
            else

                [~,mc_err,~,~,imgHi_mc]=track_CLG_TV_adv(imgHi_bic_center,imgHi_bic,DParam,DParam);

                if ADAPT_WEIGHT > 0 %adaptive motion compensation
                    ratio_mc = exp(-mc_err./ADAPT_WEIGHT);
                    ratio_bic = ones(size(imgHi_bic)) - ratio_mc;

                    imgHi_bic = ratio_bic.*imgHi_bic_center + ratio_mc.*imgHi_mc;
                    
                else
                    imgHi_bic = imgHi_mc;
                end
            end
        end

        %% convert into caffe-shape
        Xl_tmp = imgHi_bic;

        Xl_tmp = permute(Xl_tmp,[2 1 3 4]);
        tmpImgH5(:,:,layer,i) = Xl_tmp;

        %% calculate temporal image gradients -> not used for VSRnet
        if layer == framesPerBlock 
            %first derriv.
            tmpImgH5(:,:,6,i) = tmpImgH5(:,:,2,i) - tmpImgH5(:,:,4,i);
            %second derriv.g
            tmpImgH5(:,:,7,i) = (tmpImgH5(:,:,1,i) + tmpImgH5(:,:,5,i) - 2*tmpImgH5(:,:,3,i));
        end
        

    end
    toc;
end

%% return values
input_data = tmpImgH5;
input_data = {input_data};
idx_gt = (1:nrSets) + floor(framesPerBlock/2);

end

