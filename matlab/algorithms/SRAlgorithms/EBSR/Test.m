clear all;
%close all;
%Low = imread('Butterfly.bmp');
Low = imread('lena.png'); % MAGI-STUFF
%path = '~/develop/lmsSR_framework/data/output/img1001to1100direct_lmsRTCS1_TIFF_TCORRAW/';
%load([path,'img1001to1100direct_lmsRTCS1_TIFF_TCORRAW8bit_f100u4x4_h265v15m3qp0_mec33_res.mat'],'lr_ref_img');
%Low = lr_ref_img;
Low(:,:,2) = Low(:,:,1);
Low(:,:,3) = Low(:,:,1);
Low = im2uint8(Low);
%load('~/develop/lmsSR_framework/data/output/yuv201_BQMall_832x480_60_f16d4x4_h265v15m3qp0_mec33_res.mat','lr_ref_img');
% load('~/develop/lmsSR_framework/data/output/yuv601_BQMall_832x480_60_f16d4x4_h265v15m3qp0_mec33_res.mat','lr_ref_img');
% Low = lr_ref_img(:,:,1);
% Low(:,:,2) = Low(:,:,1);
% Low(:,:,3) = Low(:,:,1);
% Low = im2uint8(Low);
%Low = imread('/HOMES/baetz/SHARED_FILES/CLUSTER_SEQUENCES/HD/TECNICK_Imageset/TESTIMAGES/RGB/RGB_OR_1200x1200/RGB_OR_1200x1200_090.png'); % MAGI-STUFF

MagFactor = 4;%3;
High = SuperresCode(Low, MagFactor);    %%% magnify the input image 'Low' by the factor of 'MagFactor' along each dimension.
High = uint8(High);
imwrite(High,'HighResol.png');

%NNLow = imresize(Low, MagFactor, 'nearest');
% MAGI-STUFF-START
Low_tmp = im2double(Low);
NNLow_tmp = lmsSR_interpolate2D(Low_tmp,[MFactor, MFactor],'nearest');
NNLow = im2uint8(NNLow_tmp);
% MAGI-STUFF-END
subplot(1,2,1);
%image(NNLow(:,200:350,:)); % MAGI-STUFF
%axis image; % MAGI-STUFF
imshow(NNLow); % MAGI-STUFF
subplot(1,2,2);
%image(High(:,200:350,:)); % MAGI-STUFF
%axis image; % MAGI-STUFF
imshow(High); % MAGI-STUFF
display('done.');

%save('magiTest_yuv601_BQMall_832x480.mat'); % MAGI-STUFF
%save('magiTest_TECNICK090_4080x4080.mat'); % MAGI-STUFF
save('magiTest_lmsRTCS1_TIFF_TCORRAW8bit_nonimresize.mat'); % MAGI-STUFF
