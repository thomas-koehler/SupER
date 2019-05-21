function [sr_img_deconv, sr_img, num_pix] = lmsSR_generateSRusingNUIv3(lr_seq, warped_meshXN, warped_meshYN, upscaling, psf, lucy_iter)
%
% LMSSR_GENERATESRUSINGNUIV3 Performs a Non-Uniform Interpolation (NUI) Super-Resolution (SR) approach using Cubic Interpolation. Supports GS/Y and YUV.
%    [sr_img_deconv, sr_img, num_pix] = LMSSR_GENERATESRUSINGNUIV3(lr_seq, warped_meshXN, warped_meshYN, upscaling, psf, lucy_iter)
%
% Parameters: lr_seq          -   4-D matrix containing a LR YUV444 or GS/Y sequence (height,width,dye,frames)
%             warped_meshXN   -   Warped image mesh for X-coordinates
%             warped_meshYN   -   Warped image mesh for Y-coordinates
%             upscaling       -   1x2 vector containing the upscaling factors for Y- and X-coordinates
%             psf             -   Point spread function
%             lucy_iter       -   Number of iteration for the Lucy-Richardson deconvolution
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

% Extract information from lr_seq
[lr_height,lr_width,dye,num_imgs] = size(lr_seq);

% Build Original X-Y-Position Grid
[lr_meshX,lr_meshY] = meshgrid(1:lr_width,1:lr_height);

% Build SR X-Y-Position Grid
[sr_meshX,sr_meshY] = meshgrid(1:1/upscaling(2):lr_width+1-1/upscaling(2),1:1/upscaling(1):lr_height+1-1/upscaling(1)); % Use Grid Vectors instead

% Linearized Meshes (Direct Computation)
merged_meshX = zeros(lr_height,lr_width,num_imgs);
merged_meshY = zeros(lr_height,lr_width,num_imgs);

merged_meshX(:,:,1)     = lr_meshX;
merged_meshX(:,:,2:end) = warped_meshXN;

merged_meshY(:,:,1)     = lr_meshY;
merged_meshY(:,:,2:end) = warped_meshYN;

merged_lin_meshX = merged_meshX(~isnan(merged_meshX));
merged_lin_meshY = merged_meshY(~isnan(merged_meshY));

merged_valsY = lr_seq(:,:,1,:);

merged_lin_valsY = merged_valsY(~isnan(merged_meshX));

if dye == 3,
    merged_valsU = lr_seq(:,:,2,:);
    merged_valsV = lr_seq(:,:,3,:);
    
    merged_lin_valsU = merged_valsU(~isnan(merged_meshX));
    merged_lin_valsV = merged_valsV(~isnan(merged_meshX));
end


num_pix = numel(merged_lin_meshX);

% Memory Cleansing
%clear warped_meshXN warped_meshYN lr_seq

% SR Reconstruction using Non-Uniform Interpolation (NUI)
% Griddata-Solution (ScatteredInterpolant is called from inside the griddata function)
tmp_Y = griddata(merged_lin_meshX,merged_lin_meshY,merged_lin_valsY,sr_meshX,sr_meshY,'cubic');
tmp_Y(isnan(tmp_Y)) = 0; % Temporary NaN treatment for Y
sr_img(:,:,1) = tmp_Y;
if dye == 3, % YUV444 Input
   tmp_U = griddata(merged_lin_meshX,merged_lin_meshY,merged_lin_valsU,sr_meshX,sr_meshY,'cubic');
   tmp_V = griddata(merged_lin_meshX,merged_lin_meshY,merged_lin_valsV,sr_meshX,sr_meshY,'cubic');
   tmp_U(isnan(tmp_U)) = 127/255; % Temporary NaN treatment for U
   tmp_V(isnan(tmp_V)) = 127/255; % Temporary NaN treatment for V
   sr_img(:,:,2) = tmp_U;
   sr_img(:,:,3) = tmp_V;
end

% Padding Image for the Deblurring Step
pad_size = 16; % This was 5 prior

sr_img_tmp = padarray(sr_img,[pad_size pad_size],'replicate','both');

% SR Deblurring Step (Deconvolution)
sr_img_deconv = deconvlucy(sr_img_tmp,psf,lucy_iter); % Lucy-Richardson deconvolution for deblurring (more iterations improves the result for checkerboard)

% Remove the Pading after the Deblurring Step
sr_img_deconv = sr_img_deconv(1+pad_size:end-pad_size,1+pad_size:end-pad_size,:);

