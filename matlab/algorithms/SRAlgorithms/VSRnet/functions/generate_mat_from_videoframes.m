% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
%
% helper function to generate mat file from video frames
% --> feel free to modify and use for your own purpose
%
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% *************************************************************************
clearvars

OUTPUTPATH = 'data/lr_video/u3/foreman_u4_LR.mat';

DParam.prescaling = 1;
DParam.upscaleFactor = 4;
DParam.patchSize = 36;      
DParam.stride = 36;   

inputBasename = {'foreman_short'};
inputNrFrames = 20;

inputVidBasePath = '/home/armin/caffe/data/Superresolution/4vid/';
inputVidPath{1} = [inputVidBasePath inputBasename{1} '/original/Frame '];
inputVidPath{2} = '.png';
    
for i=1:inputNrFrames
    fileIdxStr = sprintf('%03d',i);
    filename = [inputVidPath{1} fileIdxStr inputVidPath{2}];
    
    imgRGB = im2double(imread(filename));

    %% only get Y-channel (gray) from YCbCr
    if (ndims(imgRGB)==3)
        img_ycbcr = rgb2ycbcr(imgRGB);
        imgHi = img_ycbcr(:,:,1);             
    else
        imgHi = imgRGB;
    end

    %% preprocess image
    imgHi = crop2divisibleSize(imgHi,DParam.upscaleFactor);
    imgLo = imresize(imgHi,1/DParam.upscaleFactor,'bicubic');   
   
    if i==1
        frames = zeros([size(imgLo),inputNrFrames] );
    end
    
    frames(:,:,i) = imgLo;
   
end

save(OUTPUTPATH,'frames')
