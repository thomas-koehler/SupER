function qualityMeasure = imageQuality_s3(sr, gt)

% Making sure that only functions in the S3 folder can be called
addpath(genpath('../algorithms/qualityMeasures/S3/'));

% Compute combined shaprness map.
[~, ~, s3] = s3_map(255*sr, 0);

% Average over 1% highest pixels.
thresh = quantile(s3(:), 0.99);
N = numel(s3(s3(:) >= thresh));
qualityMeasure = 1 / N * sum(s3(s3(:) >= thresh));

% Making sure that only functions in the S3 folder can be called
rmpath(genpath('../algorithms/qualityMeasures/S3/'));

