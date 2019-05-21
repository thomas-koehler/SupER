%
% Author: Marius Drulea
% http://www.cv.utcluj.ro/optical-flow.html

% References
% M. Drulea and S. Nedevschi, "Total variation regularization of 
% local-global optical flow," in Intelligent Transportation Systems (ITSC), 
% 2011 14th International IEEE Conference on, 2011, pp. 318-323.

% Copyright (C) 2011 Technical University of Cluj-Napoca

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% The file "applyBilateralFilterToDataTerms.cpp" should be recompiled if the following error occurs:
% ??? Undefined function or method
% 'applyBilateralFilterToDataTerms' for input arguments of type 'double'.
% 
% To compile this file use the "mex" function. 
% Enter the following line into the Matlab's command prompt: mex applyBilateralFilterToDataTerms.cpp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear;

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

% load images
I1 = double(imread('data/Army/frame10.png'))/255;
I2 = double(imread('data/Army/frame11.png'))/255;

show_flow = 0; % display the flow during computation
h = figure('Name', 'Optical flow');

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the flow using the coarse-to-fine warping strategy
[u v] = coarse_to_fine(I1, I2, settings, show_flow, h);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

toc


% display computed flow
figure;
flow(:, :, 1) = u;
flow(:, :, 2) = v;
imshow(flowToColor(flow, 4));
title('Computed flow');