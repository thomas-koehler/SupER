% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
%
% This script calculates the PSNR and SSIM of the VSRnet and the bicubic
% result and displays the output frames
% 
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% *************************************************************************

%% more parameters
BORDERSIZE = 8; %4+2+2; %border size = sum of all zeropaddings in model def file

if exist('im_gt')

    %% crop borders
    im_gt = permute(im_gt,[2,1,3,4])*255;

    im_SR_M = im_SR(BORDERSIZE+1:end-BORDERSIZE,BORDERSIZE+1:end-BORDERSIZE,:,:);
    im_gt_M = im_gt(BORDERSIZE+1:end-BORDERSIZE,BORDERSIZE+1:end-BORDERSIZE,:,:);
    im_bic_M = im_bic(BORDERSIZE+1:end-BORDERSIZE,BORDERSIZE+1:end-BORDERSIZE,:,:);   

    %% analyze results
    PSNR_VSRnet_results=[];
    PSNR_bicubic_results=[];
    SSIM_VSRnet_results=[];
    SSIM_bicubic_results=[];

    for imgIdx = 1:size(im_gt,4)
        % calculate PSNR
        PSNR_SR = psnr(im_SR_M(:,:,:,imgIdx),im_gt_M(:,:,:,imgIdx),255);
        PSNR_BIC = psnr(im_bic_M(:,:,:,imgIdx),im_gt_M(:,:,:,imgIdx),255); 
        SSIM_SR = ssim(im_SR_M(:,:,:,imgIdx),im_gt_M(:,:,:,imgIdx),255);
        SSIM_BIC = ssim(im_bic_M(:,:,:,imgIdx),im_gt_M(:,:,:,imgIdx),255);        
        display(['Image ' num2str(idx_gt(imgIdx)) 'PSNR VSRnet: '  num2str(PSNR_SR) ' BICUBIC: '  num2str(PSNR_BIC)]);

        PSNR_VSRnet_results(end+1) = PSNR_SR;
        PSNR_bicubic_results(end+1) = PSNR_BIC; 
        SSIM_VSRnet_results(end+1) = SSIM_SR;
        SSIM_bicubic_results(end+1) = SSIM_BIC; 

        % displayt result    
        subplot(3,1,1),imshow(uint8(im_bic_M(:,:,:,imgIdx))),title(['BICUBIC PSNR: '  num2str(PSNR_BIC)]);
        subplot(3,1,2),imshow(uint8(im_SR_M(:,:,:,imgIdx))),title(['VSRnet PSNR: '  num2str(PSNR_SR)]);
        subplot(3,1,3),imshow(uint8(im_gt_M(:,:,:,imgIdx))),title('GroundTruth');
        drawnow;      
    end
    display(['MEAN PSNR VSRnet: ' num2str(mean(PSNR_VSRnet_results)) ' BICUBIC: '  num2str(mean(PSNR_bicubic_results))])

else %if gt not available, simply show images
    im_SR_M = im_SR(BORDERSIZE+1:end-BORDERSIZE,BORDERSIZE+1:end-BORDERSIZE,:,:);
    im_bic_M = im_bic(BORDERSIZE+1:end-BORDERSIZE,BORDERSIZE+1:end-BORDERSIZE,:,:);   
    for imgIdx = 1:size(im_bic,4)
        subplot(2,1,1),imshow(uint8(im_bic_M(:,:,:,imgIdx))),title(['BICUBIC']);
        subplot(2,1,2),imshow(uint8(im_SR_M(:,:,:,imgIdx))),title(['VSRnet']);
        drawnow;   
    end
end



