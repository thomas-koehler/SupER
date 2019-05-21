function sr_img = superresolve_aplus(slidingWindows, magFactor)

% Anchored Neighborhood Regression for Fast Example-Based Super-Resolution
% Example code
%
% March 22, 2013. Radu Timofte, VISICS @ KU Leuven
%
% Revised version: (includes all [1] methods)
% October 3, 2013. Radu Timofte, CVL @ ETH Zurich
%
% Updated version: (adds A+ methods [2])
% September 5, 2014. Radu Timofte, CVL @ ETH Zurich
% %
% Please reference to both:
% [1] Radu Timofte, Vincent De Smet, Luc Van Gool.
% Anchored Neighborhood Regression for Fast Example-Based Super-Resolution.
% International Conference on Computer Vision (ICCV), 2013.
%
% [2] Radu Timofte, Vincent De Smet, Luc Van Gool.
% A+: Adjusted Anchored Neighborhood Regression for Fast Super-Resolution.
% Asian Conference on Computer Vision (ACCV), 2014.
%
% For any questions, email me by timofter@vision.ee.ethz.ch
%


% IMPORTANT NOTE: For keeping things simple, color support was removed! (MAGI-ADAPT)

lIm       = slidingWindows.referenceFrame;
upscaling = magFactor;


currentDir = pwd;
cd('../algorithms/SRAlgorithms/Aplus'); % MAGI-FIX

p = pwd;
addpath(fullfile(p, '/methods'));  % the upscaling methods

addpath(fullfile(p, '/ksvdbox')) % K-SVD dictionary training algorithm

addpath(fullfile(p, '/ompbox')) % Orthogonal Matching Pursuit algorithm

%imgscale = 1; % the scale reference we work with
% MAGI-ADAPT
%flag = 0;       % flag = 0 - only GR, ANR, A+, and bicubic methods, the other get the bicubic result by default
% flag = 1 - all the methods are applied

%input_dir = 'Set5'; % Directory with input images from Set5 image dataset

%pattern = '*.bmp'; % Pattern to process

dict_sizes = [2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536];
%neighbors = [1:1:12, 16:4:32, 40:8:64, 80:16:128, 256, 512, 1024];
%d = 7
%for nn=1:28
%nn= 28

clusterszA = 2048; % neighborhood size for A+

for d=10    %1024
    %d = 9; % 512
    %d = 8; %256
    %d = 7; %128
    %d = 6; % 64
    %d = 5; % 32
    %d=4;  %16
    %d=3;  %8
    %d=2; %4
    %d=1; %2
    
    %tag = [input_dir '_x' num2str(upscaling) '_' num2str(dict_sizes(d)) 'atoms'];
    
    mat_file = ['conf_Zeyde_' num2str(dict_sizes(d)) '_finalx' num2str(upscaling)];
    
    if exist([mat_file '.mat'],'file')
        disp(['Load trained dictionary...' mat_file]);
        load(mat_file, 'conf');
    else
        disp(['Training dictionary of size ' num2str(dict_sizes(d)) ' using Zeyde approach...']);
        % Simulation settings
        conf.scale = upscaling; % scale-up factor
        conf.level = 1; % # of scale-ups to perform
        conf.window = [3 3]; % low-res. window size
        conf.border = [0 0]; % border of the image (to ignore)
        
        % High-pass filters for feature extraction (defined for upsampled low-res.)
        conf.upsample_factor = upscaling; % upsample low-res. into mid-res.
        O = zeros(1, conf.upsample_factor-1);
        G = [1 O -1]; % Gradient
        L = [1 O -2 O 1]/2; % Laplacian
        conf.filters = {G, G.', L, L.'}; % 2D versions
        conf.interpolate_kernel = 'bicubic';
        
        conf.overlap = [1 1]; % partial overlap (for faster training)
        if upscaling <= 2
            conf.overlap = [1 1]; % partial overlap (for faster training)
        end
        
        startt = tic;
        conf = learn_dict(conf, load_images(...
            glob('CVPR08-SR/Data/Training', '*.bmp') ...
            ), dict_sizes(d));
        conf.overlap = conf.window - [1 1]; % full overlap scheme (for better reconstruction)
        conf.trainingtime = toc(startt);
        toc(startt)
        
        save(mat_file, 'conf');
        
        % train call
    end
    
    if dict_sizes(d) < 1024
        lambda = 0.01;
    elseif dict_sizes(d) < 2048
        lambda = 0.1;
    elseif dict_sizes(d) < 8192
        lambda = 1;
    else
        lambda = 5;
    end
    
    %% GR
    if dict_sizes(d) < 10000
        conf.ProjM = inv(conf.dict_lores'*conf.dict_lores+lambda*eye(size(conf.dict_lores,2)))*conf.dict_lores';
        conf.PP = (1+lambda)*conf.dict_hires*conf.ProjM;
    else
        % here should be an approximation
        conf.PP = zeros(size(conf.dict_hires,1), size(conf.V_pca,2));
        conf.ProjM = [];
    end
    
    %conf.filenames = glob(input_dir, pattern); % Cell array
    
    conf.desc = {'Original', 'Bicubic', 'Yang et al.', ...
        'Zeyde et al.', 'Our GR', 'Our ANR', ...
        'NE+LS','NE+NNLS','NE+LLE','Our A+ (0.5mil)','Our A+', 'Our A+ (16atoms)'};
    conf.results = {};
    
    %conf.points = [1:10:size(conf.dict_lores,2)];
    conf.points = [1:1:size(conf.dict_lores,2)];
    
    conf.pointslo = conf.dict_lores(:,conf.points);
    conf.pointsloPCA = conf.pointslo'*conf.V_pca';
    
    % precompute for ANR the anchored neighborhoods and the projection matrices for
    % the dictionary
    
    conf.PPs = [];
    if  size(conf.dict_lores,2) < 40
        clustersz = size(conf.dict_lores,2);
    else
        clustersz = 40;
    end
    D = abs(conf.pointslo'*conf.dict_lores);
    
    for i = 1:length(conf.points)
        [vals idx] = sort(D(i,:), 'descend');
        if (clustersz >= size(conf.dict_lores,2)/2)
            conf.PPs{i} = conf.PP;
        else
            Lo = conf.dict_lores(:, idx(1:clustersz));
            conf.PPs{i} = 1.01*conf.dict_hires(:,idx(1:clustersz))*inv(Lo'*Lo+0.01*eye(size(Lo,2)))*Lo';
        end
    end
    
    %% A+ computing the regressors
    Aplus_PPs = [];
    
    fname = ['Aplus_x' num2str(upscaling) '_' num2str(dict_sizes(d)) 'atoms' num2str(clusterszA) 'nn_5mil.mat'];
    
    if exist(fname,'file')
        load(fname);
    else
        %%
        disp('Compute A+ regressors');
        ttime = tic;
        tic
        [plores phires] = collectSamplesScales(conf, load_images(...
            glob('CVPR08-SR/Data/Training', '*.bmp')), 12, 0.98);
        
        if size(plores,2) > 5000000
            plores = plores(:,1:5000000);
            phires = phires(:,1:5000000);
        end
        number_samples = size(plores,2);
        
        % l2 normalize LR patches, and scale the corresponding HR patches
        l2 = sum(plores.^2).^0.5+eps;
        l2n = repmat(l2,size(plores,1),1);
        l2(l2<0.1) = 1;
        plores = plores./l2n;
        phires = phires./repmat(l2,size(phires,1),1);
        clear l2
        clear l2n
        
        llambda = 0.1;
        
        for i = 1:size(conf.dict_lores,2)
            D = pdist2(single(plores'),single(conf.dict_lores(:,i)'));
            [~, idx] = sort(D);
            Lo = plores(:, idx(1:clusterszA));
            Hi = phires(:, idx(1:clusterszA));
            Aplus_PPs{i} = Hi*inv(Lo'*Lo+llambda*eye(size(Lo,2)))*Lo';
            %Aplus_PPs{i} = Hi*(inv(Lo*Lo'+llambda*eye(size(Lo,1)))*Lo)';
        end
        clear plores
        clear phires
        
        ttime = toc(ttime);
        save(fname,'Aplus_PPs','ttime', 'number_samples');
        toc
    end
    
    low = {im2single(lIm)};
    
    % A+
    fprintf('A+\n');
    conf.PPs = Aplus_PPs;
    %startt = tic;
    conf.border = [0 0]; % border of the image (to ignore)
	res_img = scaleup_ANR(conf, low);
    %toc(startt)
    %conf.countedtime(10,i) = toc(startt);
    
end

sr_img = res_img{1}; % No UINT8/DOUBLE-Conversion applied

cd(currentDir);

