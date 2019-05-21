function qualityMeasure = imageQuality_sseq(sr, gt)

% Making sure that only functions in the SSEQ folder can be called
addpath(genpath('../algorithms/qualityMeasures/SSEQ/'));

path = pwd;
cd(['..', filesep, 'algorithms', filesep, 'qualityMeasures', filesep, 'SSEQ']);
qualityMeasure = - SSEQ(repmat(uint8(255*sr), 1, 1, 3));
cd(path);

% Making sure that only functions in the SSEQ folder can be called
rmpath(genpath('../algorithms/qualityMeasures/SSEQ/'));

