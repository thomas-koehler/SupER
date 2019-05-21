function SR = superresolve_dbrsr(slidingWindows, magFactor)

numberOfFrames = size(slidingWindows.frames,3);


% Set PSF kernels for the different binning factors.
psf{1} = fspecial('gaussian', 5, 0.8); % PSF for binning factor 2
psf{2} = fspecial('gaussian', 7, 1.2); % PSF for binning factor 3
psf{3} = fspecial('gaussian', 9, 1.6); % PSF for binning factor 4

% Specific preprocessing steps for the non-uniform interpolation based multi-frame methods.
weighting_struct = struct('mec_weight_flag',4,'dis_weight_flag',1,'qps_weight_flag',0,'mec_confMapN',[],...
    'mec_thr_scaler',2,'mec_weight_exp',2,'mec_weighting',[],'dis_rho',0.7,'dis_scaler',magFactor*10,'dis_weighting',[],...
    'qps_map',[],'qps_rho',0.7,'qps_weighting',[],'alpha',1,'beta',1,'gamma',1,'whi_mode',2);
warped_meshXN = zeros(size(slidingWindows.referenceFrame,1),size(slidingWindows.referenceFrame,2),numberOfFrames-1);
warped_meshYN = zeros(size(slidingWindows.referenceFrame,1),size(slidingWindows.referenceFrame,2),numberOfFrames-1);

lr_seq_sorted = slidingWindows.frames;
lr_seq_tmp = lr_seq_sorted(:,:,(numberOfFrames+1)/2);
lr_seq_sorted(:,:,(numberOfFrames+1)/2) = lr_seq_sorted(:,:,1);
lr_seq_sorted(:,:,1) = lr_seq_tmp;

lr_seq_sorted = permute(lr_seq_sorted,[1 2 4 3]);

permutation_vec = 1:numberOfFrames-1;
permutation_vec((numberOfFrames+1)/2:end) = permutation_vec((numberOfFrames+1)/2:end) + 1;
permutation_vec(1:(numberOfFrames-1)/2)   = circshift(permutation_vec(1:(numberOfFrames-1)/2),[0 -1]);

fw_optFlowN_xc = zeros(size(lr_seq_sorted,1),size(lr_seq_sorted,2),2,numberOfFrames-1);

for itera = 1:numberOfFrames-1
    [warped_meshXN(:,:,itera),warped_meshYN(:,:,itera)] = lmsSR_warpImgGridLocalTrans(size(slidingWindows.referenceFrame,1),size(slidingWindows.referenceFrame,2),slidingWindows.flowToReference{permutation_vec(itera)}.mvs_xc);
    
    % Storing the MEC-SSD-Confidence into the Weighting Struct
    weighting_struct.mec_confMapN(:,:,itera) = slidingWindows.mec_confMap{permutation_vec(itera)};
    
    % Forward MVF for WDBR
    fw_optFlowN_xc(:,:,:,itera) = slidingWindows.flowToReference{permutation_vec(itera)}.mvs_xc;
end

% Actual SR call
[~,wnuisr_nodeconv,~,~] = lmsSR_generateSRusingNUIv4weighted(lr_seq_sorted,warped_meshXN,warped_meshYN,[magFactor, magFactor],psf{magFactor-1},2,weighting_struct);
[SR,~] = lmsSR_generateSRusingWDBR(wnuisr_nodeconv,fw_optFlowN_xc,magFactor,numberOfFrames,psf{magFactor-1},2,weighting_struct);

