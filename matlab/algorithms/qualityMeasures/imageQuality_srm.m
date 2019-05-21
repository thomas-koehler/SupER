function qualityMeasure = imageQuality_srm(sr, gt)

% Making sure that only functions in the sr-metric folder can be called
addpath(genpath('../algorithms/qualityMeasures/sr-metric/'));

path = pwd;
cd(['..', filesep, 'algorithms', filesep, 'qualityMeasures', filesep, 'sr-metric']);

% Making sure that only functions in the sr-metric folder can be called
addpath('external/matlabPyrTools','external/randomforest-matlab/RF_Reg_C');

qualityMeasure = quality_predict(sr);

% Making sure that only functions in the sr-metric folder can be called
rmpath('external/matlabPyrTools','external/randomforest-matlab/RF_Reg_C');

cd(path);

% Making sure that only functions in the sr-metric folder can be called
rmpath(genpath('../algorithms/qualityMeasures/sr-metric/'));

