%% Load ground truth image and SR results from real and simulated data.
load('G:\results\baselineDatasets\coffee\Uncoded\mat\global_pan_translation_xyz_inlier_bin4_sr0_f17_win01.mat');
I_gt = srImages.groundTruth;

load('G:\results\baselineDatasets\coffee\Uncoded\mat\global_pan_translation_xyz_inlier_bin4_sr19_f17_win01.mat');
I_real = srImages.vdsr;

load('G:\results\simulatedDatasets\coffee\Uncoded\mat\global_pan_translation_xyz_inlier_bin4_sr19_f17_win01.mat');
I_simulated = srImages.vdsr;

%% Error map for real data.
ROI = [570, 420, 290, 400];
rangeIn = [1e-4 2e-1];
rangeOut = [0.15 0.85];
gamma = 0.9;

errorMap = abs(I_gt - I_real);
errorMap = errorMap(ROI(1):(ROI(1) + ROI(3) - 1), ROI(2):(ROI(2) + ROI(4) - 1));

figure;
I_real = I_real(ROI(1):(ROI(1) + ROI(3) - 1), ROI(2):(ROI(2) + ROI(4) - 1));
I_real = imadjust(I_real, [], [], gamma);
imshow(I_real);
imwrite(I_real, 'D:\Paper\cvpr2017\latex\images\teaser_real_SR.png');
figure;
errorMap = imadjust(errorMap, rangeIn, rangeOut);
imwrite(gray2ind(errorMap), jet, 'D:\Paper\cvpr2017\latex\images\teaser_real_diff.png');
imshow(errorMap);
colormap(gca, jet);

%% Error map for simulated data.
errorMap = abs(I_gt - I_simulated);
errorMap = errorMap(ROI(1):(ROI(1) + ROI(3) - 1), ROI(2):(ROI(2) + ROI(4) - 1));

figure;
I_simulated = I_simulated(ROI(1):(ROI(1) + ROI(3) - 1), ROI(2):(ROI(2) + ROI(4) - 1));
I_simulated = imadjust(I_simulated, [], [], gamma);
imshow(I_simulated);
imwrite(I_simulated, 'D:\Paper\cvpr2017\latex\images\teaser_simulated_SR.png');
figure;
errorMap = imadjust(errorMap, rangeIn, rangeOut);
imwrite(gray2ind(errorMap), jet, 'D:\Paper\cvpr2017\latex\images\teaser_simulated_diff.png');
imshow(errorMap);
colormap(gca, jet)