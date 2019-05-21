% ========================================================================
% Demo codes for dictionary training by joint sparse coding
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

% MAGI-INFO: Works on MATLABR2007b, but not on MATLABR2014a!

clear all; clc; close all;
addpath(genpath('RegularizedSC'));

TR_IMG_PATH = 'Data/Training';
%TR_IMG_PATH = 'Data/MagiTraining'; % MAGI-STUFF

dict_size   = 1024;%512;          % dictionary size
lambda      = 0.15;         % sparsity regularization
patch_size  = 5;            % image patch size
nSmp        = 100000;       % number of patches to sample
upscale     = 3;            % upscaling factor

% randomly sample image patches
[Xh, Xl] = rnd_smp_patch(TR_IMG_PATH, '*.bmp', patch_size, nSmp, upscale);
%[Xh, Xl] = rnd_smp_patch(TR_IMG_PATH, '*.png', patch_size, nSmp, upscale); % MAGI-STUFF

% prune patches with small variances, threshould chosen based on the
% training data
[Xh, Xl] = patch_pruning(Xh, Xl, 10);

% joint sparse coding 
%[Dh, Dl] = train_coupled_dict(Xh, Xl, dict_size, lambda); % MAGI-STUFF
[Dh, Dl] = train_coupled_dict(Xh, Xl, dict_size, lambda,upscale); % MAGI-STUFF
%dict_path = ['Dictionary/D_' num2str(dict_size) '_' num2str(lambda) '_' num2str(patch_size) '.mat' ];
dict_path = ['Dictionary/MagiD_' num2str(dict_size) '_' num2str(lambda) '_' num2str(patch_size) '.mat' ]; % MAGI-STUFF
save(dict_path, 'Dh', 'Dl');