function qualityMeasure = imageQuality_niqe(sr, gt)

% Making sure that only functions in the NIQE folder can be called
addpath(genpath('../algorithms/qualityMeasures/NIQE/'));

load modelparameters.mat
blocksizerow = 96;
blocksizecol = 96;
blockrowoverlap = 0;
blockcoloverlap = 0;
qualityMeasure = - computequality(255*sr, blocksizerow, blocksizecol, blockrowoverlap, blockcoloverlap, mu_prisparam, cov_prisparam);

% Making sure that only functions in the NIQE folder can be called
rmpath(genpath('../algorithms/qualityMeasures/NIQE/'));

