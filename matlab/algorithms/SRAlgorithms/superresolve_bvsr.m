 function I_sr = superresolve_bvsr(slidingWindow, magFactor)
    
    vid_l_bic = slidingWindow.frames;
    
    % Reshape input images from 3-D array to cell array.
    if ~iscell(vid_l_bic)
        if ndims(vid_l_bic) == 3
            for j = 1:size(vid_l_bic,3)
                I{j}(:,:,1) = vid_l_bic(:,:,j);
                I{j}(:,:,2) = vid_l_bic(:,:,j);
                I{j}(:,:,3) = vid_l_bic(:,:,j);
            end
            vid_l_bic = I;
        end
    end
    
    % Set parameters
    param.LINUX = 1;
    param.MOTION_ESTIMATION = 1;
    param.OPTICAL_FLOW = 1;
    param.BLUR_ESTIMATION = 1;
    param.NOISE_ESTIMATION = 1;
    param.SHOW_IMAGE = 0;
    param.SAVE_RESULT = 1;
    param.MAKE_VIDEO = 0;

    opt(1).nref = round((length(vid_l_bic) - 1) / 2); % num of reference frames (one-side)
    opt(1).res = magFactor; % for scale factor
    opt(1).maxit = 5; % maximum iteration number
    opt(1).eps = 0.0005;         % iteration stop criteria
    opt(1).eps_out = 0.0001;    % iteration stop criteria
    opt(1).eps_blur = 0.0001;    % iteration stop criteria
    opt(1).eta = 20; % for derivative of image
    opt(1).xi = 0.7; % for derivative of kernel
    opt(1).alpha = 1;  % for noise
    opt(1).beta = 0.1; % for noise
    opt(1).degrad = 0; % 0:imresize, 1:LPF+downsampling
    opt(1).hsigma = 0.4*magFactor; % for degradation (blur kernel)
    opt(1).hsize = round(6*magFactor*0.4); % for degradation (blur kernel)
    if mod(opt(1).hsize, 2) == 0
        opt(1).hsize = opt(1).hsize + 1;
    end
    opt(1).noisesd = 0; % for degradation (noise st.dev.) 0,0.01,0.03,0.05
    if param.BLUR_ESTIMATION % Initialization of estimated blur kernel (h_2d)
        opt(1).hmode_init = 1; % 1:gaussian, 2:uniform
        opt(1).hsigma_init = 0.4*magFactor;
    end

    for l = 1:length(opt)

        opt(l).nFrames = length(vid_l_bic);
        opt(l).maxnbf = min(opt(l).nFrames, opt(l).nref); % maximum frame numbers for reference

        [opt(l).M,opt(l).N] = size(vid_l_bic{1}(:,:,1)); % height and width of high-res image
        opt(l).M = opt(1).res * opt(l).M;
        opt(l).N = opt(1).res * opt(l).N;
        [opt(l).m,opt(l).n] = size(vid_l_bic{1}(:,:,1)); % height and widht of low-res image
        M = opt(l).M; 
        N = opt(l).N;

        h_2d_sim = fspecial('gaussian', [opt(l).hsize opt(l).hsize], opt(l).hsigma); % blur kernel
        if param.BLUR_ESTIMATION
            [h_1d,h_2d_init] = create_h1(opt(l));
            h_2d = h_2d_init;
        else
            h_2d = h_2d_sim;
        end

        J = extract_y(vid_l_bic);
        I_init = create_initial_I(J,opt(l).res, h_2d);

        % Initialize the variables
        W0 = zeros(opt(l).m,opt(l).n); % for weight matrix for high-res img
        Ws = zeros(M,N); % for weight matrix for derivative
        Wk = zeros(M,N); % for weight matrix for kernel
        Wi = []; % for weight matrix for high-res img (neighboring frames)
        I_sr = I_init; % initialization for super-resolved image

        % Loop for each frame
        for j = round((opt(l).nFrames + 1) / 2)

            n_back = min(opt(l).maxnbf, j-1);
            n_for = min(opt(l).maxnbf, opt(l).nFrames-j);
            th = ones(n_for+n_back+1, 1); % for noise estimation

            % Coordinate descent algorithm
            I = I_init{j}; % current frame (high-res)
            J0 = J{j}; % current frame (low-res)
            for i = -n_back:n_for
                FI{j+i} = I_init{j+i};
            end

            %  Outer iteration
            for k = 1:opt(l).maxit % Loop for each sweep of the algorithm

                I_old_out = I;

                % (1) Estimate motion
                % IRLS
                % motion estimation with optical flow algorithm
                if param.MOTION_ESTIMATION && param.OPTICAL_FLOW
                    for i = -n_back:n_for
                        if i == 0
                            u{j+i} = zeros(size(I)); 
                            v{j+i} = zeros(size(I));
                            ut{j+i} = zeros(size(I)); 
                            vt{j+i} = zeros(size(I));
                        else            
                            %[u{j+i},v{j+i}] = opticalFlow_CLG_TV(I,I_sr{j+i}); % I->Ii(J_bic)
                            oflParams = [0.025, ...  % Regularization weight
                                0.5, ...    % Downsample ratio
                                20, ...     % Width of image pyramid coarsest level
                                7, ...      % Number of outer fixed point iterations
                                1, ...      % Number of inner fixed point iterations
                                20];        % Number of SOR iterations
                            [u{j+i},v{j+i}] = Coarse2FineTwoFrames(I, I_sr{j+i}, oflParams);
                            %[ut{j+i},vt{j+i}] = Coarse2FineTwoFrames(I_sr{j+i}, I, oflParams);
                            ut{j+i} = -u{j+i}; 
                            vt{j+i} = -v{j+i};
                            FI{j+i} = warped_img(I,u{j+i},v{j+i});
                        end
                    end
                end

                % (2) Estimate noise
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

                % (3) Estimate high-res img
                % IRLS
                for m = 1:opt(l).maxit
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
                    AI = zeros(M,N); 
                    b = zeros(M,N);
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
                        break;
                    end
                end

                % (4) Estimate kernel
                % IRLS
                if param.BLUR_ESTIMATION
                    K = otf2psf(psf2otf(h_2d,size(I))); % 2d kernel (Kx x Ky)
                    for m = 1:opt(l).maxit-2
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
                            break;
                        end
                    end
                    half = floor(opt(l).hsize/2);
                    h_2d = K(M/2-half+1:M/2+half+1,N/2-half+1:N/2+half+1);
                    h_2d = h_2d / sum(sum(h_2d));
                end

                % (5) Check convergence
                diff_out = norm(I-I_old_out)/norm(I_old_out);
                if diff_out < opt(l).eps_out
                    break;
                end
                        
            end

            I_sr{j} = I;

        end
        
        % Correct offset
        if opt(l).degrad == 0
            I_sr = shift_adjust(I_sr,opt(l).res,-1);
        end
        I_sr = I_sr{round((opt(l).nFrames + 1) / 2)}(:,:,1);
        
    end

    clear W0 Ws Wk Wi;