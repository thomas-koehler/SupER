function stat = calc_statistics(elapsedTime,vid_est,vid_org,vid_bic,opt)
% *************************************************************************
% Superresolution with Dictionary Technique
% getTrainingStatistics 
%
% calculate statistic values for the superresolution process
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         03/21/2013
%
% Modifications:
% 
% *************************************************************************

L = 1; %dynamic range

if iscell(vid_est) 
%% for videos
    for i = 1:opt.nFrames
        % statistics about image quality
        [stat_rmse(i),stat_psnr(i),stat_ssim(i)] = doCalculations(vid_est{i},vid_org{i},L);
    end
    stat.elapsed_time = elapsedTime;
    stat.rmse = sum(stat_rmse)/(opt.nFrames);
    stat.psnr = sum(stat_psnr)/(opt.nFrames);
    stat.ssim = sum(stat_ssim)/(opt.nFrames);    
    
    %calculate rmse and psnr for bicubic, if given
    if ~isempty(vid_bic)
        stat_rmse = [];
        stat_psnr = [];
        stat_ssim = [];
        for i = 1:opt.nFrames
            [stat_rmse(i), stat_psnr(i), stat_ssim(i)] = doCalculations(vid_bic{i},vid_org{i},L);
        end
        stat.rmse_bicubic_interpolation = sum(stat_rmse)/(opt.nFrames);
        stat.psnr_bicubic_interpolation = sum(stat_psnr)/(opt.nFrames);  
        stat.ssim_bicubic_interpolation = sum(stat_ssim)/(opt.nFrames); 
        
    end
    
    stat
    
else 
%% for images
    % statistics about optimization
    stat.elapsed_time = elapsedTime;

    % statistics about image quality
    [stat.rmse, stat.psnr, stat.ssim] = doCalculations(vid_est,vid_org,L);
    
    if ~isempty(vid_bic)
        [stat.rmse_bicubic_interpolation, stat.psnr_bicubic_interpolation, stat.ssim_bicubic_interpolation] = doCalculations(vid_bic,vid_org,L);     
    end
end

end

%% do the calculations for the image quality
function [stat_rmse, stat_psnr, stat_ssim] = doCalculations(img1,img2,L)

    if size(img1, 3) == 3
        img1 = rgb2ycbcr(img1);
        img1 = img1(:, :, 1);
    end
    
    if size(img2, 3) == 3
        img2 = rgb2ycbcr(img2);
        img2 = img2(:, :, 1);
    end

    % shave the border 
    border = 5;
    img1 = img1(border+1:end-border, border+1:end-border);
    img2 = img2(border+1:end-border, border+1:end-border);

    img1 = double(img1);
    img2 = double(img2);

    if 0
        if max(max(img1)) > 50
            img1 = img1/256;
        end

        if max(max(img2)) > 50
            img2 = img2/256;
        end

        img1(find(img1>1)) = 1;
        img1(find(img1<0)) = 0;
    end
    
    img1(find(img1>1)) = 1;
    img1(find(img1<0)) = 0;
    
    m = sum((img1(:)-img2(:)).^2) / numel(img1); 

    stat_rmse = sqrt(m);
%     stat_rmse = compute_rmse(img1, img2);
    stat_psnr = 10*log10(L^2/m);
%     stat_psnr = 20*log10(255/stat_rmse);
    stat_ssim = ssim(img1,img2,L);

end

% calculates ISNR (not used yet)
function value=ISNR(imgOrig,imgObserved,imgReconstr)
    value=10*log10(sum(sum(abs(imgOrig-imgObserved).^2))/sum(sum(abs(imgOrig-imgReconstr).^2)));
end

                
