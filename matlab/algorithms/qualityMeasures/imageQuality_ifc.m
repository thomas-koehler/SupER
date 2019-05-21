function qualityMeasure = imageQuality_ifc(sr, gt)

% Making sure that only functions in the ifc folder can be called
addpath(genpath('../algorithms/qualityMeasures/ifc/'));

qualityMeasure = ifcvec(255*gt, 255*sr);

% Making sure that only functions in the ifc folder can be called
rmpath(genpath('../algorithms/qualityMeasures/ifc/'));

