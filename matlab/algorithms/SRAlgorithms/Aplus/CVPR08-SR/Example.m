% Image super-resolution using sparse representation
% Example code
%
% Nov. 2, 2007. Jianchao Yang
% IFP @ UIUC
%
% Revised version. April, 2009.
%
% Reference
% Jianchao Yang, John Wright, Thomas Huang and Yi Ma. Image superresolution
% via sparse representation of raw image patches. IEEE Computer Society
% Conference on Computer Vision and Pattern Recognition (CVPR), 2008. 
%
% For any questions, email me by jyang29@illinois.edu

clear all;
clc;

addpath('Solver');
addpath('Sparse coding');

% =====================================================================
% specify the parameter settings

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 3; % zooming factor, if you change this, the dictionary needs to be retrained.

tr_dir = 'Data/training'; % path for training images
skip_smp_training = true; % sample training patches
skip_dictionary_training = true; % train the coupled dictionary
num_patch = 50000; % number of patches to sample as the dictionary
codebook_size = 1024; % size of the dictionary

regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution

if ~skip_smp_training,
    disp('Sampling image patches...');
    [Xh, Xl] = rnd_smp_dictionary(tr_dir, patch_size, zooming, num_patch);
    save('Data/Dictionary/smp_patches.mat', 'Xh', 'Xl');
    skip_dictionary_training = false;
end;

if ~skip_dictionary_training,
    load('Data/Dictionary/smp_patches.mat');
    [Dh, Dl] = coupled_dic_train(Xh, Xl, codebook_size, lambda);
    save('Data/Dictionary/Dictionary.mat', 'Dh', 'Dl');
else
    load('Data/Dictionary/Dictionary.mat');
end;

% =====================================================================
% Process the test image 

fname = 'Data/Test/1.bmp';
testIm = imread(fname); % testIm is a high resolution image, we downsample it and do super-resolution

if rem(size(testIm,1),zooming) ~=0,
    nrow = floor(size(testIm,1)/zooming)*zooming;
    testIm = testIm(1:nrow,:,:);
end;
if rem(size(testIm,2),zooming) ~=0,
    ncol = floor(size(testIm,2)/zooming)*zooming;
    testIm = testIm(:,1:ncol,:);
end;

imwrite(testIm, 'Data/Test/high.bmp', 'BMP');

lowIm = imresize(testIm,1/zooming, 'bicubic');
imwrite(lowIm,'Data/Test/low.bmp','BMP');

interpIm = imresize(lowIm,zooming,'bicubic');
imwrite(uint8(interpIm),'Data/Test/bb.bmp','BMP');

% work with the illuminance domain only
lowIm2 = rgb2ycbcr(lowIm);
lImy = double(lowIm2(:,:,1));

% bicubic interpolation for the other two channels
interpIm2 = rgb2ycbcr(interpIm);
hImcb = interpIm2(:,:,2);
hImcr = interpIm2(:,:,3);

% ======================================================================
% Super-resolution using sparse representation

disp('Start superresolution...');

[hImy] = L1SR(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres);

ReconIm(:,:,1) = uint8(hImy);
ReconIm(:,:,2) = hImcb;
ReconIm(:,:,3) = hImcr;

nnIm = imresize(lowIm, zooming, 'nearest');
figure, imshow(nnIm);
title('Input image');
pause(1);
figure, imshow(interpIm);
title('Bicubic interpolation');
pause(1)

ReconIm = ycbcr2rgb(ReconIm);
figure,imshow(ReconIm,[]);
title('Our method');
imwrite(uint8(ReconIm),'Data/Test/L1SR.bmp','BMP');