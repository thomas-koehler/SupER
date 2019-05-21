function [sr_img_deconv, sr_img, sampled_img, sr_affix] = lmsSR_generateSRusingNUIv4weighted(lr_seq, warped_meshXN, warped_meshYN, upscaling, psf, lucy_iter, weighting_struct)
%
% LMSSR_GENERATESRUSINGNUIV4WEIGHTED Performs a Non-Uniform Interpolation (NUI) Super-Resolution (SR) approach with Spatial Quantization using Cubic Interpolation 
%                                    and a Triple Sample Weighting. Supports GS/Y and YUV.
%    [sr_img_deconv, sr_img, sampled_img, sr_affix] = LMSSR_GENERATESRUSINGNUIV4WEIGHTED(lr_seq, warped_meshXN, warped_meshYN, upscaling, psf, lucy_iter, weighting_struct)
%
% Parameters: lr_seq             -   4-D matrix containing a LR YUV444 or GS/Y sequence (height,width,dye,frames)
%             warped_meshXN      -   Warped image mesh for X-coordinates
%             warped_meshYN      -   Warped image mesh for Y-coordinates
%             upscaling          -   1x2 vector containing the upscaling factors for Y- and X-coordinates
%             psf                -   Point spread function
%             lucy_iter          -   Number of iteration for the Lucy-Richardson deconvolution
%             weighting_struct   -   Struct containing the selected weighting mode + corresponding extra information:
%
%                mec_weight_flag   -   MEC Weighting ON/OFF (0: OFF. 1: ON, 2: ON [MECv2], 3: ON [MECv3], 4: ON [MECv4])
%                dis_weight_flag   -   Distance Weighting ON/OFF
%                qps_weight_flag   -   QP Weighting ON/OFF
%
%                mec_confMapN      -   3-D matrix containing confidence information in form of SSD values for each pixel and each auxiliary frame
%                mec_thr_scaler    -   Scalar value responsible for scaling the standard deviation threshold which cuts off SSD values that are too large [default: 2]
%                mec_weight_exp    -   Exponent for intensifying the weighting [default: 2]
%                mec_weighting     -   3-D matrix containing weights for each pixel depending on the quality of the MEC step
%
%                dis_rho           -   Distance Weighting Decay Factor [default: 0.7]
%                dis_scaler        -   Distance Weighting Scaling Factor [default: upscaling*10]
%                dis_weighting     -   3-D matrix containing weights for each pixel depending on the distance to the nearest pixel center
%
%                qps_map           -   3-D matrix containing the quantization parameters for each pixel and each frame including the reference frame
%                qps_rho           -   Quantization Weighting Decay Factor [default: 0.7]
%                qps_weighting     -   3-D matrix containing weights for each pixel depending on the quantization parameters
%
%                alpha             -   MEC Weighting Mixing Factor [default: 1]
%                beta              -   Distance Weighting Mixing Factor [default: 1]
%                gamma             -   Quantization Weighting Mixing Factor [default: 1]
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

sr_affix = 'sr2weighted000';

if weighting_struct.mec_weight_flag == 1,
    sr_affix(end-2) = '1';
elseif weighting_struct.mec_weight_flag == 2,
    sr_affix(end-2) = '2';
elseif weighting_struct.mec_weight_flag == 3,
    sr_affix(end-2) = '3';
elseif weighting_struct.mec_weight_flag == 4,
    sr_affix(end-2) = '4';
end

if weighting_struct.dis_weight_flag == 1,
    sr_affix(end-1) = '1';
elseif weighting_struct.dis_weight_flag == 2,
    sr_affix(end-1) = '2';
end

if weighting_struct.qps_weight_flag,
    sr_affix(end) = '1';
end

disp(['Weighting-Mode [',sr_affix(end-2:end),'] Selected..']);

alpha = weighting_struct.alpha;
beta  = weighting_struct.beta;
gamma = weighting_struct.gamma;

% Extract information from lr_seq
[lr_height,lr_width,dye,num_imgs] = size(lr_seq);

% Build Original X-Y-Position Grid
[lr_meshX,lr_meshY] = meshgrid(1:lr_width,1:lr_height);

% Build SR X-Y-Position Grid (+Padding)
[sr_meshX,sr_meshY] = meshgrid(1:lr_width*upscaling(2)+2*upscaling(2),1:lr_height*upscaling(1)+2*upscaling(1));


% Computing MEC weights from SSD values
if weighting_struct.mec_weight_flag == 1,
    weighting_struct.mec_weighting = lmsSR_computeWeightsMEC(weighting_struct.mec_confMapN,weighting_struct.mec_thr_scaler,weighting_struct.mec_weight_exp);
elseif weighting_struct.mec_weight_flag == 2,
    weighting_struct.mec_weighting = lmsSR_computeWeightsMECv2(weighting_struct.mec_confMapN,weighting_struct.mec_thr_scaler,weighting_struct.mec_weight_exp);
elseif weighting_struct.mec_weight_flag == 3,
    weighting_struct.mec_weighting = lmsSR_computeWeightsMECv3(weighting_struct.mec_confMapN,weighting_struct.mec_thr_scaler,weighting_struct.mec_weight_exp);
elseif weighting_struct.mec_weight_flag == 4,
    weighting_struct.mec_weighting = lmsSR_computeWeightsMECv4(weighting_struct.mec_confMapN,weighting_struct.mec_thr_scaler*10,weighting_struct.mec_weight_exp); % MAGI-ADD: Scaling with 10 necessary!
else
    weighting_struct.mec_weighting = ones(lr_height,lr_width,num_imgs);
end

% Computing QP weights from quantization parameters
if weighting_struct.qps_weight_flag, % MAGI-TODO: Work-in-Progress
    weighting_struct.qps_weighting = lmsSR_computeWeightsQP(weighting_struct.qps_map,weighting_struct.qps_rho);
else
    weighting_struct.qps_weighting = ones(lr_height,lr_width,num_imgs);
end


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

% Removing NaN-Positions of the QP/MEC Weighting Matrix and Linearizing It
merged_mec_weighting = weighting_struct.mec_weighting(~isnan(merged_meshX));
merged_qps_weighting = weighting_struct.qps_weighting(~isnan(merged_meshX));

num_pix = numel(merged_lin_meshX);

disp('... Throwing points into spatially quantized buckets ...');
%timeSR2bucket = tic;

% Averaging all samples inside the HR grid pixel patch
rounded_meshX = round(merged_lin_meshX*upscaling(2)) - upscaling(2) + 1;
rounded_meshY = round(merged_lin_meshY*upscaling(1)) - upscaling(1) + 1;

rounding_errX = abs(merged_lin_meshX - (rounded_meshX + upscaling(2) - 1)/upscaling(2));
rounding_errY = abs(merged_lin_meshY - (rounded_meshY + upscaling(1) - 1)/upscaling(1));

% Memory Cleansing
clear warped_meshXN warped_meshYN lr_seq lr_meshX lr_meshY merged_meshX merged_meshY merged_valsY merged_valsU merged_valsV merged_lin_meshX merged_lin_meshY mec_weighting

% Throwing away all mesh points that lie outside the SR image grid
outlier_vec = (rounded_meshX < 1) | (rounded_meshX > lr_width*upscaling(2)) | (rounded_meshY < 1) | (rounded_meshY > lr_height*upscaling(1));

rounded_meshX = rounded_meshX(~outlier_vec);
rounded_meshY = rounded_meshY(~outlier_vec);

rounding_errX = rounding_errX(~outlier_vec);
rounding_errY = rounding_errY(~outlier_vec);

% Distance Weighting Stuff
if weighting_struct.dis_weight_flag == 1,
    weighting_struct.dis_weighting = weighting_struct.dis_rho.^(sqrt((rounding_errY*weighting_struct.dis_scaler(1)).^2 + (rounding_errX*weighting_struct.dis_scaler(1)).^2));
elseif weighting_struct.dis_weight_flag == 2,
    weighting_struct.dis_weighting = weighting_struct.dis_rho.^(sqrt((rounding_errY*weighting_struct.dis_scaler(1)/2).^2 + (rounding_errX*weighting_struct.dis_scaler(1)/2).^2));
else
    weighting_struct.dis_weighting = ones(size(rounding_errX));
end

merged_lin_valsY = merged_lin_valsY(~outlier_vec);

tmp_sr_imgY = zeros(lr_height*upscaling(1),lr_width*upscaling(2)); % Creating bucketed image
if dye == 3,
    merged_lin_valsU = merged_lin_valsU(~outlier_vec);
    merged_lin_valsV = merged_lin_valsV(~outlier_vec);
    
    tmp_sr_imgU = zeros(lr_height*upscaling(1),lr_width*upscaling(2)); % Creating bucketed image
    tmp_sr_imgV = zeros(lr_height*upscaling(1),lr_width*upscaling(2)); % Creating bucketed image
end

merged_mec_weighting = merged_mec_weighting(~outlier_vec);
merged_qps_weighting = merged_qps_weighting(~outlier_vec);

counter_matrix = zeros(lr_height*upscaling(1),lr_width*upscaling(2)); % Matrix for counting the number of entries in each bucket
weighting_matrix = zeros(lr_height*upscaling(1),lr_width*upscaling(2)); % Matrix for the sum of MEC-DIS-QPS weights

num_pix = num_pix - sum(outlier_vec);

if dye == 3, % Color case
    for itera = 1:num_pix,
        % Weighted case
        tmp_sr_imgY(rounded_meshY(itera),rounded_meshX(itera))    = tmp_sr_imgY(rounded_meshY(itera),rounded_meshX(itera)) + merged_lin_valsY(itera)*alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
        tmp_sr_imgU(rounded_meshY(itera),rounded_meshX(itera))    = tmp_sr_imgU(rounded_meshY(itera),rounded_meshX(itera)) + merged_lin_valsU(itera)*alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
        tmp_sr_imgV(rounded_meshY(itera),rounded_meshX(itera))    = tmp_sr_imgV(rounded_meshY(itera),rounded_meshX(itera)) + merged_lin_valsV(itera)*alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
        
        counter_matrix(rounded_meshY(itera),rounded_meshX(itera))   = counter_matrix(rounded_meshY(itera),rounded_meshX(itera)) + 1;
        weighting_matrix(rounded_meshY(itera),rounded_meshX(itera)) = weighting_matrix(rounded_meshY(itera),rounded_meshX(itera)) + alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
    end
    
    % Weighted case
    tmp_sr_imgY = tmp_sr_imgY ./ weighting_matrix;
    tmp_sr_imgU = tmp_sr_imgU ./ weighting_matrix;
    tmp_sr_imgV = tmp_sr_imgV ./ weighting_matrix;
else % Grayscale case
    for itera = 1:num_pix,
        % Weighted case
        tmp_sr_imgY(rounded_meshY(itera),rounded_meshX(itera))    = tmp_sr_imgY(rounded_meshY(itera),rounded_meshX(itera)) + merged_lin_valsY(itera)*alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
        
        counter_matrix(rounded_meshY(itera),rounded_meshX(itera))   = counter_matrix(rounded_meshY(itera),rounded_meshX(itera)) + 1;
        weighting_matrix(rounded_meshY(itera),rounded_meshX(itera)) = weighting_matrix(rounded_meshY(itera),rounded_meshX(itera)) + alpha*merged_mec_weighting(itera)*beta*weighting_struct.dis_weighting(itera)*gamma*merged_qps_weighting(itera);
    end

    % Weighted case
    tmp_sr_imgY = tmp_sr_imgY ./ weighting_matrix;
end

disp('... Throwing points into spatially quantized buckets: Done.');
%toc(timeSR2bucket);

sampled_img = tmp_sr_imgY;
if dye == 3,
    sampled_img(:,:,2) = tmp_sr_imgU;
    sampled_img(:,:,3) = tmp_sr_imgV;
end

disp('... Interpolating data to the HR grid ...');
%timeSR2interp = tic;

% For Cubic Interpolation a slight Padding is required to avoid incorrectly interpolated values near the image borders
tmp_sr_imgY = padarray(tmp_sr_imgY,upscaling,'symmetric','both');
if dye == 3,
    tmp_sr_imgU = padarray(tmp_sr_imgU,upscaling,'symmetric','both');
    tmp_sr_imgV = padarray(tmp_sr_imgV,upscaling,'symmetric','both');
end

% Bringing the bucketed image into a linearized form for the griddata call
bucket_meshX = sr_meshX(~isnan(tmp_sr_imgY));
bucket_meshY = sr_meshY(~isnan(tmp_sr_imgY));

bucket_valsY  = tmp_sr_imgY(~isnan(tmp_sr_imgY));
if dye == 3,
    bucket_valsU  = tmp_sr_imgU(~isnan(tmp_sr_imgY));
    bucket_valsV  = tmp_sr_imgV(~isnan(tmp_sr_imgY));
end

% SR Reconstruction using Non-Uniform Interpolation (NUI)
% Griddata-Solution (ScatteredInterpolant is called from inside the griddata function)
tmp_Y = griddata(bucket_meshX,bucket_meshY,bucket_valsY,sr_meshX,sr_meshY,'cubic');%,'linear');
tmp_Y(isnan(tmp_Y)) = 0; % Temporary NaN treatment for Y
sr_img(:,:,1) = tmp_Y;
if dye == 3, % YUV444 Input
  tmp_U = griddata(bucket_meshX,bucket_meshY,bucket_valsU,sr_meshX,sr_meshY,'cubic');%,'linear');
  tmp_V = griddata(bucket_meshX,bucket_meshY,bucket_valsV,sr_meshX,sr_meshY,'cubic');%,'linear');
  tmp_U(isnan(tmp_U)) = 127/255; % Temporary NaN treatment for U
  tmp_V(isnan(tmp_V)) = 127/255; % Temporary NaN treatment for V
  sr_img(:,:,2) = tmp_U;
  sr_img(:,:,3) = tmp_V;
end
%sr_affix = [sr_affix,'lin'];

% Cropping the Padding
sr_img = sr_img(1+upscaling(1):end-upscaling(1),1+upscaling(2):end-upscaling(2),:);

disp('... Interpolating data to the HR grid: Done.');
%toc(timeSR2interp);

disp('... Deblurring SR image ...');
%timeSR2deblur = tic;

% Padding Image for the Deblurring Step
pad_size = 16; % This was 5 prior

sr_img_tmp = padarray(sr_img,[pad_size pad_size],'replicate','both');

% SR Deblurring Step (Deconvolution)
sr_img_deconv = deconvlucy(sr_img_tmp,psf,lucy_iter); % Lucy-Richardson deconvolution for deblurring (more iterations improves the result for checkerboard)

% Remove the Pading after the Deblurring Step
sr_img_deconv = sr_img_deconv(1+pad_size:end-pad_size,1+pad_size:end-pad_size,:);

disp('... Deblurring SR image: Done.');
%toc(timeSR2deblur);

