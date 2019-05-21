function [vectors,errors_full_final,xPos,yPos,frame2to1_y,xPosv,yPosv] = track_CLG_TV_adv(frame1,frame2,DParam,srParam)
% *************************************************************************
% Superresolution with Dictionary Technique
% trackPatches with sub-pixel precision 
%
% finds corresponding patches from two frames and returns a 3 dimensional
% matrix with the motion vectors
% 
% the difference between this adv version and basic version is the way of
% interpolation. The basic version do interpolation with the regid square
% while this adv version do it with deformable way and produce one more
% output frame2to1, (y channel in ycbcr) which transform frame 2 according to the motion field
% to frame 1.
% 
% Version 1.0
%
% Created by:   Qiqin Dai (Tim)
% Date:         05/23/2013
%
% Modifications:
% 03/04/2014     Armin Kappeler
% file can handle grayscale/y-channel images as input
% can use stride instead of overlap
% 
% *************************************************************************

%% Get parameters
patchSize = DParam.patchSize;

if mod(patchSize,2) == 0
    half_patchSize = patchSize/2;
else
    half_patchSize = (patchSize-1)/2;
end

if isfield(srParam,'overlap')
    overlap = srParam.overlap;
else
    overlap = DParam.patchSize - DParam.stride;
end

%% Setting for the CLG_TV algorithm
settings.lambda = 2200; % the weighting of the data term
settings.pyramid_factor = 0.5;
settings.resampling_method = 'bicubic'; % the resampling method used to build pyramids and upsample the flow
settings.warps = 5; % the number of warps per level
settings.interpolation_method = 'cubic'; % the interpolation method used for warping
settings.its = 10; % the number of iterations used for minimization
settings.use_diffusion = 1; % apply a weighting factor to the regularization term (the diffusion coefficient)
settings.use_bilateral = 1; % the data term weighting: bilateral or gaussian
settings.wSize = 5; % the window's size for the data fidelity term (Lukas-Kanade)
settings.sigma_d = settings.wSize/6; % sigma for the distance gaussian of the bilateral filter
settings.sigma_r = 0.1; % sigma for the range gaussian of the bilateral filter
settings.use_ROF_texture = 0; % apply ROF texture to the images (1 yes, 0 no)
settings.ROF_texture_factor = 0.95; % ROF texture; I = I - factor*ROF(I); 
show_flow = 0; % display the flow during computation
h = 0;%figure('Name', 'Optical flow');

%% Get image size from frame1, assume frame1 and frame2 are the same size
n_size = size(frame1);
maxX = n_size(2) - patchSize + 1;
maxY = n_size(1) - patchSize + 1;
%% Vectorize the position of each patch
[xPos, yPos] = meshgrid(1:patchSize-overlap:maxX,1:patchSize-overlap:maxY);
xPos = xPos(:);
yPos = yPos(:);
%% Optical flow

if size(frame1,3)==3
    frame1_ycbcr = rgb2ycbcr(frame1);
    frame2_ycbcr = rgb2ycbcr(frame2);
    frame1_y = frame1_ycbcr(:,:,1);
    frame2_y = frame2_ycbcr(:,:,1);
else
    frame1_y = frame1;
    frame2_y = frame2;
end


[u v] = coarse_to_fine(frame1_y, frame2_y, settings, show_flow, h);

% uv = estimate_flow_interface(frame1, frame2, 'classic+nl-fast');
% Considering the origin point of pathes are the left-up corner and the
% patch size
% uv_interest = uv(1+half_patchSize:maxY+half_patchSize,1+half_patchSize:maxX+half_patchSize,:);

%% Stack the motion field into vector
vectors = zeros(length(xPos),2);
% temp = uv_interest(:,:,1);
% temp = uv(:,:,1);
temp = u;
% vectors(:,1) = temp(sub2ind(size(uv(:,:,1)),yPos,xPos));
vectors(:,1) = temp(sub2ind(size(u),yPos,xPos));
% temp = uv_interest(:,:,2);
temp = v;
% vectors(:,2) = temp(sub2ind(size(uv(:,:,1)),yPos,xPos));
vectors(:,2) = temp(sub2ind(size(v),yPos,xPos));

%% Calculate frame2to1
% xPosv and yPosv should be of full size of the input frame
% frame1_gray = double(rgb2gray(frame1));
% frame2_gray = double(rgb2gray(frame2));
% frame1_ycbcr = rgb2ycbcr(frame1);
% frame2_ycbcr = rgb2ycbcr(frame2);
% frame1_y = frame1_ycbcr(:,:,1);
% frame2_y = frame2_ycbcr(:,:,1);
% [xPosv, yPosv] = meshgrid(1:patchSize-overlap:n_size(2),1:patchSize-overlap:n_size(1));
[xPosv, yPosv] = meshgrid(1:1:n_size(2),1:1:n_size(1));
% vectors_full is the full size motion field
vectors_full = zeros(n_size(1),n_size(2),2);
% vectors_full(:,:,1) = uv(:,:,1);
% vectors_full(:,:,2) = uv(:,:,2);

vectors_full(:,:,1) = u;
vectors_full(:,:,2) = v;

xPosv = xPosv+vectors_full(:,:,1);
yPosv = yPosv+vectors_full(:,:,2);
xPosv = reshape(xPosv,n_size(1),n_size(2));
yPosv = reshape(yPosv,n_size(1),n_size(2));

xPosv(xPosv <= 1) = 1;
yPosv(yPosv <= 1) = 1;
xPosv(xPosv >= n_size(2)) = n_size(2);
yPosv(yPosv >= n_size(1)) = n_size(1);


% frame2to1 = zeros(n_size(1),n_size(2),3);
% frame2to1(:,:,1) = interp2(double(frame2(:,:,1)),xPosv,yPosv,'cubic');
% frame2to1(:,:,2) = interp2(double(frame2(:,:,2)),xPosv,yPosv,'cubic');
% frame2to1(:,:,3) = interp2(double(frame2(:,:,3)),xPosv,yPosv,'cubic');
% frame2to1_gray = interp2(frame2_gray,xPosv,yPosv,'cubic');

frame2to1_y = interp2(frame2_y,xPosv,yPosv,'cubic');
% figure;
% imshow(frame2to1./256);
% 
% figure;
% imshow(frame2to1_gray./256);
% 
% figure;
% imshow(frame1_gray./256);
% 
% figure;
% imshow(frame2_gray./256);

%% Calculate the matching error by OII technique
% errors_full = abs(frame2to1_gray - frame1_gray);
errors_full = abs(frame2to1_y - frame1_y);
% Horizontal intergal image
errors_full_hi = zeros(n_size(1),n_size(2));
errors_full_hi(:,1) = errors_full(:,1);
for i = 2:n_size(2)
    errors_full_hi(:,i) = errors_full_hi(:,i-1) + errors_full(:,i);
end
% Horizontal propagate
errors_full_hi = [zeros(n_size(1),1),errors_full_hi];
errors_full_hp = zeros(n_size(1),n_size(2)+1);
for i = half_patchSize+1+1:n_size(2)-half_patchSize+1
    errors_full_hp(:,i) = errors_full_hi(:,i+half_patchSize) - errors_full_hi(:,i-half_patchSize-1);
end
errors_full_hp = errors_full_hp(:,2:end);
% Vertical intergal image
errors_full_vi = zeros(n_size(1),n_size(2));
errors_full_vi(1,:) = errors_full_hp(1,:);
for i = 2:n_size(1)
    errors_full_vi(i,:) = errors_full_vi(i-1,:) + errors_full_hp(i,:);
end
% Vertical propagate
errors_full_vi = [zeros(1,n_size(2));errors_full_vi];
errors_full_vp = zeros(n_size(1)+1,n_size(2));
for i = half_patchSize+1+1:n_size(1)-half_patchSize+1
    errors_full_vp(i,:) = errors_full_vi(i+half_patchSize,:) - errors_full_vi(i-half_patchSize-1,:);
end
errors_full_final = errors_full_vp(2:end,:);


errors = errors_full_final((xPos+half_patchSize-1)*n_size(1)+yPos+half_patchSize);


end

