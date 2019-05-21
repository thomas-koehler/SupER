function mec_weighting = lmsSR_computeWeightsMECv4(mec_confMapN, mec_thr_scaler, mec_weight_exp)
%
% LMSSR_COMPUTEWEIGHTSMECV4 Computes weights depending on the quality of the motion estimation/compensation stage. (Version 4: One global threshold, adapted by number of images)
%    mec_weighting = LMSSR_COMPUTEWEIGHTSMECV4(mec_confMapN, mec_thr_scaler, mec_weight_exp)
%
% Parameters: mec_confMapN     -   3-D matrix containing confidence information in form of SSD values for each pixel and each auxiliary frame
%             mec_thr_scaler   -   Scalar value responsible for scaling the standard deviation threshold which cuts off SSD values that are too large [default: 20]
%             mec_weight_exp   -   Exponent for intensifying the weighting [default: 2]
%
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

[height,width,num_imgs] = size(mec_confMapN);

% 1-SSD Weighting + Setting SSD values larger than twice the standard deviation to 0
mec_weighting   = ones(height,width,num_imgs+1); % Highest weight is set to 1 => Reference frame weights need no further adaptation
mec_conf_stddev = std(mec_confMapN(:));
mec_weighting(:,:,2:end) = 1 - (mec_confMapN / (mec_thr_scaler*(1/num_imgs)*mec_conf_stddev)); % SSD values larger than threshold_scaler times standard deviation are set to 0 [default: 20]
mec_weighting(mec_weighting < 0) = 0;

%mec_weighting(mec_weighting > 0) = 1; % QUICK-TEST
mec_weighting = mec_weighting.^mec_weight_exp; % Default: 2

