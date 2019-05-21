function qualityMeasure = imageQuality_brisque(sr, gt)

% Making sure that only functions in the BRISQUE folder can be called
addpath(genpath('../algorithms/qualityMeasures/BRISQUE/'));

path = pwd;
cd(['..', filesep, 'algorithms', filesep, 'qualityMeasures', filesep, 'BRISQUE']);
qualityMeasure = - brisquescore(255*sr);
cd(path);

% Making sure that only functions in the BRISQUE folder can be called
rmpath(genpath('../algorithms/qualityMeasures/BRISQUE/'));

