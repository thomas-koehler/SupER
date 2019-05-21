function hysr_img = superresolve_hysr(slidingWindows, magFactor)

numberOfFrames = size(slidingWindows.frames,3);


% Explicit intermediate SR calculations for proper time measurements instead of simply loading previously stored intermediate SR results
sisr_img = superresolve_ebsr(slidingWindows,magFactor);
misr_img = superresolve_nuisr(slidingWindows,magFactor);

% Load SISR image
%if exist([res_path,'_bin',num2str(magFactor),'_sr1','_f',num2str(numberOfFrames),'_win',num2str(slidingWindowIdx,'%02d'),'.mat'],'file'), %EBSR
%    load([res_path,'_bin',num2str(magFactor),'_sr1','_f',num2str(numberOfFrames),'_win',num2str(slidingWindowIdx,'%02d'),'.mat']);
%    
%    sisr_img = srImages.ebsr;
%else
%    error('File not found!');
%end

% Load MISR image    
%if exist([res_path,'_bin',num2str(magFactor),'_sr5','_f',num2str(numberOfFrames),'_win',num2str(slidingWindowIdx,'%02d'),'.mat'],'file'), %NUISR
%    load([res_path,'_bin',num2str(magFactor),'_sr5','_f',num2str(numberOfFrames),'_win',num2str(slidingWindowIdx,'%02d'),'.mat']);
%    
%    misr_img = srImages.nuisr;
%else
%    error('File not found!');
%end

% Specific preprocessing steps for the non-uniform interpolation based multi-frame methods.
permutation_vec = 1:numberOfFrames-1;
permutation_vec((numberOfFrames+1)/2:end) = permutation_vec((numberOfFrames+1)/2:end) + 1;
permutation_vec(1:(numberOfFrames-1)/2)   = circshift(permutation_vec(1:(numberOfFrames-1)/2),[0 -1]);

bw_optFlowN_xc = zeros(size(slidingWindows.frames,1),size(slidingWindows.frames,2),2,numberOfFrames-1);

for itera = 1:numberOfFrames-1
    % Backward MVF for HYSR
    bw_optFlowN_xc(:,:,:,itera) = slidingWindows.flowFromReference{permutation_vec(itera)}.mvs_xc;
end

% Hybrid-Mask-Creation
hyb_mask_set = bw_optFlowN_xc(:,:,1,:);

hyb_mask_set(~isnan(hyb_mask_set)) = 1;
hyb_mask_set(isnan(hyb_mask_set))  = 0;

sum_hyb_mask  = sum(hyb_mask_set,4);

interp_sum_hyb_mask  = lmsSR_interpolate2D(sum_hyb_mask,[magFactor,magFactor],'nearest');
interp_sum_hyb_mask(1:magFactor:end,1:magFactor:end) = numberOfFrames;

% Color Handling
% interp_sum_hyb_mask_color  = repmat(interp_sum_hyb_mask,[1 1 3]);

% ZeroMotionVector Mask Creation for Replacement of MISR with SISR at static background
zerovec_mask_set = round(bw_optFlowN_xc*magFactor)/magFactor;
zerovec_mask_set(zerovec_mask_set ~= 0) = 1;
zerovec_mask_tmp = sum(zerovec_mask_set,4);

zerovec_mask = zeros(size(sum_hyb_mask));
zerovec_mask(zerovec_mask_tmp(:,:,1) == 0 & zerovec_mask_tmp(:,:,2) == 0) = 1;

interp_zerovec_mask = lmsSR_interpolate2D(zerovec_mask,[magFactor,magFactor],'nearest');
% interp_zerovec_mask_color = repmat(interp_zerovec_mask,[1 1 3]);

% Without Morphological Operations
% alpha = (interp_sum_hyb_mask_color.^2)/(numberOfFrames.^2);
alpha = (interp_sum_hyb_mask.^2)/(numberOfFrames.^2);
hysr_img = misr_img .* alpha + sisr_img .* (1-alpha);
% hysr_img_ssd_quad = sisr_img .* interp_zerovec_mask_color + hysr_img_ssd_quad .* (1-interp_zerovec_mask_color);
hysr_img = sisr_img .* interp_zerovec_mask + hysr_img .* (1-interp_zerovec_mask);

