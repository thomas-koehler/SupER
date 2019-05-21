function qualityMeasure = imageQuality_msssim(sr, gt)

% Making sure that only functions in the msssim folder can be called
addpath(genpath('../algorithms/qualityMeasures/msssim/'));

K = [0.01 0.03];
winsize = 11;
sigma = 1.5;
window = fspecial('gaussian', winsize, sigma);
level = 5;
weight = [0.0448 0.2856 0.3001 0.2363 0.1333];
method = 'product';

qualityMeasure = ssim_mscale_new(255*gt, 255*sr, K, window, level, weight, method);

% Making sure that only functions in the msssim folder can be called
rmpath(genpath('../algorithms/qualityMeasures/msssim/'));

