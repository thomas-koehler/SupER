% =========================================================================
% Simple demo codes for image super-resolution via sparse representation
%
% Reference
%   J. Yang et al. Image super-resolution as sparse representation of raw
%   image patches. CVPR 2008.
%   J. Yang et al. Image super-resolution via sparse representation. IEEE 
%   Transactions on Image Processing, Vol 19, Issue 11, pp2861-2873, 2010
%
% Jianchao Yang
% ECE Department, University of Illinois at Urbana-Champaign
% For any questions, send email to jyang29@uiuc.edu
% =========================================================================

%clear all; clc;

% MAGI-STUFF
%res_name = 'lena_dictMagiD1024s4';
res_name = 'test_lena_bla';

% read test image
%im_l = imread('Data/Testing/input.bmp'); % MAGI-CHECK
%im_l = imread('lena.png'); % MAGI-TEST-1
im_l = test_deg_3_uint; % MAGI-TEST-2
% MAGI-TEST-2
% load('~/develop/lmsSR_framework/data/output/img1001to1100direct_lmsRTCS1_TIFF_TCORRAW8bit_f100u4x4_h265v15m3qp0_mec33_res.mat','lr_ref_img');
% im_l = lr_ref_img;
% im_l(:,:,2) = im_l(:,:,1);
% im_l(:,:,3) = im_l(:,:,1);
% im_l = im2uint8(im_l);

% set parameters
lambda = 0.2;                   % sparsity regularization
overlap = 4;                    % the more overlap the better (patch size 5x5)
up_scale = 2;                   % scaling factor, depending on the trained dictionary
maxIter = 20;                   % if 0, do not use backprojection

% load dictionary
%load('Dictionary/D_1024_0.15_5.mat');
load('Dictionary/MagiD_1024_0.15_5_s2.mat');

% change color space, work on illuminance only
im_l_ycbcr = rgb2ycbcr(im_l);
im_l_y = im_l_ycbcr(:, :, 1);
im_l_cb = im_l_ycbcr(:, :, 2);
im_l_cr = im_l_ycbcr(:, :, 3);

% image super-resolution based on sparse representation
[im_h_y] = ScSR(im_l_y, up_scale, Dh, Dl, lambda, overlap);
[im_h_y] = backprojection(im_h_y, im_l_y, maxIter);

% upscale the chrominance simply by "bicubic" 
[nrow, ncol] = size(im_h_y);
im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');

im_h_ycbcr = zeros([nrow, ncol, 3]);
im_h_ycbcr(:, :, 1) = im_h_y;
im_h_ycbcr(:, :, 2) = im_h_cb;
im_h_ycbcr(:, :, 3) = im_h_cr;
im_h = ycbcr2rgb(uint8(im_h_ycbcr));

% bicubic interpolation for reference
im_b = imresize(im_l, [nrow, ncol], 'bicubic');

% read ground truth image
%im = imread('Data/Testing/gnd.bmp');

% compute PSNR for the illuminance channel
%bb_rmse = compute_rmse(im, im_b);
%sp_rmse = compute_rmse(im, im_h);
%
%bb_psnr = 20*log10(255/bb_rmse);
%sp_psnr = 20*log10(255/sp_rmse);
%
%fprintf('PSNR for Bicubic Interpolation: %f dB\n', bb_psnr);
%fprintf('PSNR for Sparse Representation Recovery: %f dB\n', sp_psnr);

% show the images
figure, imshow(im_h);
title('Sparse Recovery');
figure, imshow(im_b);
title('Bicubic Interpolation');

% MAGI-STUFF
sisr_img = im_h;
interp_img = im_b;
save(['/HOMES/baetz/develop/matlab_stuff/SISR_Packages/ScSR/ScSR/Data/MagiData/',res_name,'_res.mat'],'sisr_img','interp_img');

