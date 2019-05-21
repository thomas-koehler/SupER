function [u v] = opticalFlow_CLG_TV(frame1_y, frame2_y)

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
disp('optical flow - CLG_TV');

%tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the flow using the coarse-to-fine warping strategy
[u v] = coarse_to_fine(frame1_y, frame2_y, settings, show_flow, 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%toc
