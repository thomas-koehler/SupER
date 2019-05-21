% *************************************************************************
%     Implementation of Bayesian Video Super-Resolution Method [1]
%
% Implemented by:  Seunghwan Yoo
% Affiliation:     IVPL, Northwestern University
% Email:           seunghwanyoo2013@u.northwestern.edu
% Date:            05/2014
% 
% [1] C. Liu, and D. Sun, "On Bayesian Adaptive Video Super Resolution,"
% IEEE Trans. on Pattern Analysis and Machine Intelligence, Feb. 2014.
% *************************************************************************

clear all; close all;
addpath(genpath('.'));

%% Set parameters
param.LINUX = 1;
param.MOTION_ESTIMATION = 1;
param.OPTICAL_FLOW = 1;
param.BLUR_ESTIMATION = 1;
param.NOISE_ESTIMATION = 1;
param.SHOW_IMAGE = 0;
param.SAVE_RESULT = 1;
param.MAKE_VIDEO = 0;

video{1}.imgPath = './Data/city/';
video{1}.scene = 1; 
video{1}.nFrame = 5;%34; 

opt(1).test_video = video{1};
opt(1).nref = 2; % num of reference frames (one-side)
opt(1).res = 4; % for scale factor
opt(1).maxit = 5; % maximum iteration number
opt(1).eps = 0.0005;         % iteration stop criteria
opt(1).eps_out = 0.0001;    % iteration stop criteria
opt(1).eps_blur = 0.0001;    % iteration stop criteria
opt(1).eta = 0.02; % for derivative of image
opt(1).xi = 0.7; % for derivative of kernel
opt(1).alpha = 1;  % for noise
opt(1).beta = 0.1; % for noise
opt(1).degrad = 1; % 0:imresize, 1:LPF+downsampling
opt(1).hsize = 15;   % for degradation (blur kernel)
opt(1).hsigma = 1.6; % for degradation (blur kernel) 1.2,1.6,2.0,2.4
opt(1).noisesd = 0; % for degradation (noise st.dev.) 0,0.01,0.03,0.05
if param.BLUR_ESTIMATION % Initialization of estimated blur kernel (h_2d)
  opt(1).hmode_init = 1; % 1:gaussian, 2:uniform
  opt(1).hsigma_init = 2.0;
end
% opt(2) = opt(1);
% opt(2).hsigma_init = 0.6;


for l = 1:length(opt)
    
    opt(l).nFrames = opt(l).test_video.nFrame; %34;
    opt(l).maxnbf = min(opt(l).nFrames, opt(l).nref); % maximum frame numbers for reference
    opt(l)
    
    %% Create low-res frames
    % load_video option - 1:576x704,3:288x352,4:144x176,5:64x64,6:32x64
    [vid_h_org,vid_l_bic] = load_video1(opt(l),1,param);
    %[vid_h_org,vid_l_bic] = load_myanmar_4k(opt(l),opt(l).res,6); %0(4k),1,3(1/4),6(1/8),8(1/8,corner)
     
    [opt(l).M,opt(l).N] = size(vid_h_org{1}(:,:,1)); % height and width of high-res image
    [opt(l).m,opt(l).n] = size(vid_l_bic{1}(:,:,1)); % height and widht of low-res image
    M = opt(l).M; N = opt(l).N;

    h_2d_sim = fspecial('gaussian', [opt(l).hsize opt(l).hsize], opt(l).hsigma); % blur kernel
    if param.BLUR_ESTIMATION
		if param.SHOW_IMAGE
	        figure, imagesc(h_2d_sim); title('blur kernel');
		end
	    [h_1d,h_2d_init] = create_h1(opt(l));
	    h_2d = h_2d_init;
    else
        h_2d = h_2d_sim;
    end

    % Original high-res y
    ycbcr_h_orig = convert_rgb2ycbcr(vid_h_org);
    y_org = extract_y(ycbcr_h_orig);  % original video

    if opt(l).degrad == 1
        % Degradation with S, K, opt.noisem/noisev
        vid_l = create_low_vid_s(vid_h_org,h_2d_sim,opt(l)); % downsampling & blur
        ycbcr_l = convert_rgb2ycbcr(vid_l);
        ycbcr_l = addnoise(ycbcr_l,0,opt(l).noisesd*opt(l).noisesd);
    else
        vid_l = vid_l_bic;
        ycbcr_l = convert_rgb2ycbcr(vid_l);
    end

    % Bicubic interpolation
    vid_bic = interp_bicubic(vid_l,opt(l).res);
    ycbcr_h_bic = interp_bicubic(ycbcr_l, opt(l).res);

    J = extract_y(ycbcr_l); % observation
    I_init = create_initial_I(J,opt(l).res, h_2d);

    %% Initialize the variables
    W0 = zeros(opt(l).m,opt(l).n); % for weight matrix for high-res img
    Ws = zeros(M,N); % for weight matrix for derivative
    Wk = zeros(M,N); % for weight matrix for kernel
    Wi = []; % for weight matrix for high-res img (neighboring frames)
    I_sr = I_init; % initialization for super-resolved image

    tic;

    %% Loop for each frame
    for j = 1:opt(l).nFrames % Loop for each frame
    %for j = 2:opt(l).nFrames-1 % Loop for each frame

        fprintf('SR for %d th frame \n', j);
        n_back = min(opt(l).maxnbf, j-1);
        n_for = min(opt(l).maxnbf, opt(l).nFrames-j);
        th = ones(n_for+n_back+1, 1); % for noise estimation


        %% Coordinate descent algorithm
        I = I_init{j}; % current frame (high-res)
        J0 = J{j}; % current frame (low-res)
        for i = -n_back:n_for
           FI{j+i} = I_init{j+i};
        end
        
        %  Outer iteration 
        for k = 1:opt(l).maxit % Loop for each sweep of the algorithm
            
            fprintf('%d th iteration for frame %d ... \n', k, j);
            I_old_out = I;

            %% (1) Estimate motion
            % IRLS
            % motion estimation with optical flow algorithm
            if param.MOTION_ESTIMATION && param.OPTICAL_FLOW
                fprintf('  motion estimation...\n');
	            for i = -n_back:n_for
	                if i == 0
	                   u{j+i} = zeros(size(I)); v{j+i} = zeros(size(I));
	                   ut{j+i} = zeros(size(I)); vt{j+i} = zeros(size(I));
                    else
	                   [u{j+i},v{j+i}] = opticalFlow_CLG_TV(I,I_sr{j+i}); % I->Ii(J_bic)
	                   ut{j+i} = -u{j+i}; vt{j+i} = -v{j+i};
	                   FI{j+i} = warped_img(I,u{j+i},v{j+i});
	                end
				end
            end


            %% (2) Estimate noise
            Nq = opt(l).m*opt(l).n;
            if k == 1
               for i = -n_back:n_for
                   th(j+i) = max(1,max(n_back,n_for)) / (abs(i)+1);
               end
            else
               for i = -n_back:n_for
                   if i == 0
                       KI = cconv2d(h_2d,I);
                       SKI = down_sample(KI,opt(l).res);
                       x_tmp = sum(sum(abs(J{j+i}-SKI))) / Nq;
                       th(j+i) = (opt(l).alpha+Nq-1)/(opt(l).beta+Nq*x_tmp);
                   else
                       KFI = cconv2d(h_2d,FI{j+i});
                       SKFI = down_sample(KFI,opt(l).res);
                       x_tmp = sum(sum(abs(J{j+i}-SKFI)))/Nq;
                       th(j+i) = (opt(l).alpha+Nq-1)/(opt(l).beta+Nq*x_tmp);
                   end
               end
            end
            %th  % estimated noise

           
            %% (3) Estimate high-res img
            % IRLS
            fprintf('  hig-res img estimation...\n');
            for m = 1:opt(l).maxit
                if param.SHOW_IMAGE
                    fprintf('  %d th IRLS iter \n',m);
                end
                I_old_in = I;
                % compute W0,Ws,Wi
                W0 = compute_W0(I,J0,h_2d,opt(l).res);
                Ws = compute_Ws(I);
                if param.MOTION_ESTIMATION
	                for i = -n_back:n_for
	                   if i ~= 0
	                       FI{j+i} = warped_img(I,u{j+i},v{j+i});
	                       Wi{j+i} = compute_Wi(FI{j+i},J{j+i},h_2d,opt(l).res);
	                   end
	                end
                end

               % estimat I
                AI = zeros(M,N); b = zeros(M,N);
                if param.MOTION_ESTIMATION
	                AI = compute_Ax_h(I,W0,Ws,th,h_2d,opt(l),j,n_back,n_for,FI,Wi,ut,vt,param);
	                b = compute_b_h(J,W0,th,h_2d,opt(l),j,n_back,n_for,Wi,ut,vt,param);
	                I = conj_gradient_himg(AI,I,b,W0,Ws,th,h_2d,opt(l),j,n_back,n_for,FI,Wi,ut,vt,param);
                else 
                    AI = compute_Ax(I,W0,Ws,th(j),h_2d,opt(l));
                    b = compute_b1(J0,W0,th(j),h_2d,opt(l));
                    I = conj_gradient_himg_0(AI,I,b,W0,Ws,th(j),h_2d,opt(l),param);
                end 
               % stop criteria
               diff_in = norm(I-I_old_in)/norm(I_old_in);
               if diff_in < opt(l).eps
                   if param.SHOW_IMAGE
                       fprintf('  break; diff_in < %f \n',opt(l).eps);
                   end
                   break;
               end
           end

           
           %% (4) Estimate kernel
           % IRLS
           if param.BLUR_ESTIMATION
               fprintf('  blur estimation...\n');
               K = otf2psf(psf2otf(h_2d,size(I))); % 2d kernel (Kx x Ky)
               for m = 1:opt(l).maxit-2
                   if param.SHOW_IMAGE
                       fprintf('  %d th IRLS iter \n',m);
                   end
                   K_old = K;
                   % compute W0,Ws,Wi
                   Wk = compute_Wk(K,I,J0,opt(l).res);
                   Ws = compute_Ws(K);
                   % estimat Kx
                   AK = compute_Ax_k(K,Wk,Ws,th(j),I,opt(l));
                   b = compute_b1_k(J0,Wk,th(j),I,opt(l));
                   K = conj_gradient_kernel(AK,K,b,Wk,Ws,th(j),I,opt(l),param);
                   % stop criteria
                   diff_K = norm(K-K_old)/norm(K_old);
                   if diff_K < opt(l).eps_blur
                       if param.SHOW_IMAGE
                           fprintf('  break; diff_K < %f \n',opt(l).eps_blur);
                       end
                       break;
                   end
               end
               half = floor(opt(l).hsize/2);
               h_2d = K(M/2-half+1:M/2+half+1,N/2-half+1:N/2+half+1);
               h_2d = h_2d / sum(sum(h_2d));
           end


            %% (5) Check convergence
            diff_out = norm(I-I_old_out)/norm(I_old_out);
            if diff_out < opt(l).eps_out
               fprintf('converge! norm(I-I_old)/norm(I_old) < %f \n',opt(l).eps_out);
               break;
            end

        end
        
        elapsed_time = toc
        I_sr{j} = I;
        
    end

    %% Statistics and results
    % Bayesian method
    vid_result = convert_y2rgb(I_sr,ycbcr_h_bic);
    if opt(l).degrad == 0
        vid_result = shift_adjust(vid_result,opt(l).res,-1);
    end
    figure, imshow(vid_result{2}); title('sr bayesian (frame2)');
    % Bicubic method
    if opt(l).degrad == 1
        vid_bic = shift_adjust(vid_bic,opt(l).res,1);
    end
    figure, imshow(vid_bic{2}); title('sr bicubic (frame2)');
    % estimated blur kernel
    if param.BLUR_ESTIMATION
	    h_2d_est(:,:,l) = h_2d; 
	    if param.SHOW_IMAGE
	        figure, imagesc(h_2d); title('est blur kernel');
	    end
    end
    % statistics
    %stat(l) = calc_statistics(elapsed_time,vid_result,vid_h_org,vid_bic,opt(l));
    stat(l) = calc_statistics_detail(elapsed_time,vid_result,vid_h_org,vid_bic,opt(l));

    % save the results
    if l == 1
        filename = 'bayesian';
        result_path = ['Result/' datestr(now,'yyyymmdd_HHMM')];
        mkdir(result_path);
    end
    result_filename = [result_path '/' datestr(now,'yyyymmdd_HHMM_') filename int2str(opt(l).test_video.scene)];
    if param.LINUX
        opt1 = opt(l); stat1 = stat(l);
        save([result_filename '_stat_' num2str(l)], 'opt1', 'stat1');
    else
        saveXLSData([result_filename '_stat_' num2str(l)],opt(l),stat(l));
    end
    
    if param.SAVE_RESULT
        if param.BLUR_ESTIMATION
            save([result_filename '_' num2str(l) '.mat'], 'vid_result','h_2d_est','stat');
            %save([result_filename '_1.mat'], 'vid_result','h_2d_est','stat');
        else
            save([result_filename '_' num2str(l) '.mat'], 'vid_result','stat');
        end
        if param.MAKE_VIDEO
            writeMovie([result_filename '_' num2str(l) '_sr.avi'],vid_result);
            writeMovie([result_filename '_' num2str(l) '_orig.avi'],vid_h_org);
            writeMovie([result_filename '_' num2str(l) '_low.avi'],vid_l);
            writeMovie([result_filename '_' num2str(l) '_bic.avi'],vid_bic);
        end
    end

end

clear W0 Ws Wk Wi;
disp('=== DONE ===');
