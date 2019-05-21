% ----- Global evaluation parameters -----
% Range of binning factors used for this evaluation.
binningFactors = [2, 3, 4];
% Range of compression levels (index 1 means uncoded; indices 2-5 mean 
% coded with the corresponding QP setting using H.265/HEVC coder.
compressions   = [NaN, 10, 20, 30, 40];
% Range of number of frames for SR at the different binning factors.
numberOfFrames = [11, ...   % Number of frames for binning factor 2
                  11, ...   % Number of frames for binning factor 3
                  11];      % Number of frames for binning factor 4
% Index of the first reference frame for sliding window processing.
startReferenceFrame = 35;

% ----- Settings considered for this evaluation -----
% This is the index of the SR method that is evaluated.
x = SRMethods;
sr_method           = find(strcmp({x(:).type}, 'mfsr'));
% This is the index of the binning factor that is evaluated.
binning_val         = 1:3;
% This is the index of the compression setting.
compress_val        = 1;
% This is the index that indicates the number of input frames.
numberOfFrames_val  = 1;
% This is the index of the scene according to datasets.mat.
scenes_val          = 1:14;
% This is the index of the sliding window that is evaluated.
sliding_val         = 1:6;