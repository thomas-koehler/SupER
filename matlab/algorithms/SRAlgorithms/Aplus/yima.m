function ReconIm = yima(lowIm, upscaling)
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
d = 'CVPR08-SR';
addpath(d, [d '/Solver'], [d '/Sparse_coding'], [d '/Sparse_coding/sc2']);
tr_dir = 'CVPR08-SR/Data/Training'; % path for training images
% =====================================================================
% specify the parameter settings
patch_size = 3; % patch size for the low resolution input image
overlap = 2; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 3; % zooming factor, if you change this, the dictionary needs to be retrained.

if exist('upscaling','var')
    zooming = upscaling; % zooming factor, if you change this, the dictionary needs to be retrained.
end

regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution
if zooming==3
    load([d '/Data/Dictionary/Dictionary.mat']);
else
    if ~exist([d '/Data/Dictionary/Dictionary' num2str(zooming) '.mat'],'file')
        num_patch = 50000; % number of patches to sample as the dictionary
        codebook_size = 1024; % size of the dictionary

        regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
        % =====================================================================
        % training coupled dictionaries for super-resolution
        if ~exist([d '/Data/Dictionary/smp_patches' num2str(zooming) '.mat'],'file')
            disp('Sampling image patches...');
            [Xh, Xl] = rnd_smp_dictionary(tr_dir, patch_size, zooming, num_patch);
            save([d '/Data/Dictionary/smp_patches' num2str(zooming) '.mat'], 'Xh', 'Xl');
        else
            load ([d '/Data/Dictionary/smp_patches' num2str(zooming) '.mat']);
        end
        
        [Dh, Dl] = coupled_dic_train(Xh, Xl, codebook_size, lambda);
        save([d '/Data/Dictionary/Dictionary' num2str(zooming) '.mat'], 'Dh', 'Dl');
    else
        load([d '/Data/Dictionary/Dictionary' num2str(zooming) '.mat']);
    end
end
% ======================================================================
% Super-resolution using sparse representation
disp('Start superresolution...');
ReconIm = L1SR(lowIm, zooming, patch_size, overlap, Dh, Dl, lambda, regres);
