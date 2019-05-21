function confidence_map = lmsSR_computeConfidenceMapForMotionVectors(cur_img, ref_img, mvs, upscaling)
%
% LMSSR_COMPUTECONFIDENCEMAPFORMOTIONVECTORS Estimates a confidence map for given motion information.
%    confidence_map = LMSSR_COMPUTECONFIDENCEMAPFORMOTIONVECTORS(cur_img, ref_img, mvs, upscaling)
%
% Parameters: cur_img     -   Current image
%             ref_img     -   Reference image
%             mvs         -   Motion information (First dim: MV_X, second dim: MV_Y)
%             upscaling   -   1x2 vector containing the upscaling factors for Y- and X-coordinates
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

blk_size = 5;
blk_size_half = floor(blk_size/2);

% Isotropic Weighting Matrix
rho = 0.7;
[pos_x,pos_y] = meshgrid(0:blk_size-1,0:blk_size-1); % Important: Starting index = 0 for correct centering
ssd_weighting = rho.^(sqrt((pos_y - (blk_size-1)/2).^2 + (pos_x - (blk_size-1)/2).^2));

[height, width, ~] = size(ref_img);

confidence_map = zeros(height,width);

% Round motion vectors to multiples of 1/upscaling
rounded_mvs = round(mvs*upscaling(1));

max_mv = squeeze(ceil(max(max(abs(rounded_mvs/upscaling(1))))));
max_hr_mv = max_mv * upscaling(1);

padded_cur_img = padarray(cur_img,[blk_size_half blk_size_half],'replicate','both');
padded_ref_img = padarray(ref_img,[blk_size_half+max_mv(2) blk_size_half+max_mv(1)],'replicate','both');

padded_hr_ref_img = lmsSR_interpolate2D(padded_ref_img,upscaling,'cubic');

% Block-Extraction & SSD-Calculation
for y_itera = 1:height,
    for x_itera = 1:width,
        cur_blk = padded_cur_img(y_itera:y_itera + 2*blk_size_half,x_itera:x_itera + 2*blk_size_half);
        
        cur_mv = squeeze(rounded_mvs(y_itera,x_itera,:));
        
        ref_pos_y = y_itera*upscaling(1) - upscaling(1) + 1 + cur_mv(2) + max_hr_mv(2);
        ref_pos_x = x_itera*upscaling(2) - upscaling(2) + 1 + cur_mv(1) + max_hr_mv(1);
        
        ref_blk = padded_hr_ref_img(ref_pos_y:upscaling(1):ref_pos_y + 2*upscaling(1)*blk_size_half,ref_pos_x:upscaling(2):ref_pos_x + 2*upscaling(2)*blk_size_half);
        
        % Actual SSD calculation - Weighted
        confidence_map(y_itera,x_itera) = (sum(sum(ssd_weighting.*((ref_blk - cur_blk).^2)))) / (sum(sum(ssd_weighting)));
    end
end

