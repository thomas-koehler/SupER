function [dbrsr_img_deconv, dbrsr_img] = lmsSR_generateSRusingWDBR(sr_img, transMotion, upscaling, numberOfFrames, psf, lucy_iter, weighting_struct)
%
% Important Note: Training was conducted on 6S15 in a separate script!
%
% Author: Michel Bätz (LMS)

%% ==========================================  Actual Reconstruction Only  ==============================================================

sigmas = 0.5:0.5:50;
nSigma = length(sigmas);
TH_MAX = 0.8;   % pctg from the highest indicator, for clipping effective data

% SR image
sr = 255*sr_img(:,:,1);

rows = size(sr_img,1) / upscaling;
cols = size(sr_img,2) / upscaling;

% === Obtain floating mesh ===

posRows = zeros(rows, cols, numberOfFrames);
posCols = zeros(rows, cols, numberOfFrames);
posRows(:,:,1) = meshgrid(1:rows, 1:cols)';
posCols(:,:,1) = meshgrid(1:cols, 1:rows);

for k = 1:numberOfFrames-1,
    for i = 1:rows,
        for j = 1:cols,
            posRows(i,j, k+1) = posRows(i,j) + transMotion(i,j,2,k);
            posCols(i,j, k+1) = posCols(i,j) + transMotion(i,j,1,k);
        end
    end
end

weights = lmsSR_computeWeightsMECv4(weighting_struct.mec_confMapN, 20, 2); % MAGI-NOTE: Using MEC-Weight 4

weights = weights(:);
posRows = posRows(:);
posCols = posCols(:);
weights = weights(~isnan(posRows));
posCols = posCols(~isnan(posRows));
posRows = posRows(~isnan(posRows));

posRows = posRows*upscaling - upscaling + 1;
posCols = posCols*upscaling - upscaling + 1;

% MAGI: Needs to be done in case of loading CNT too
rows = rows*upscaling;
cols = cols*upscaling;

% === Counting pixels (by tiles) ===

radius = 8;
SIGMA_SOFT = 1;

%imgReg = zeros(rows, cols); % MAGI-MEMORY-FIX
cnt = zeros(rows, cols, 3);

% Get tile borders
TH = 1e10;
LIM = radius+2;
FACTOR_MAX = 32;
Frows = 2;
Fcols = 2;
OPT_DIM = 60;
for i = 2:FACTOR_MAX
    if mod(rows, i) == 0
        d = abs(rows/i - OPT_DIM);
        if d < TH
            TH = d;
            Frows = i;
        end
    end
end
TH = 1e10;
for i = 2:FACTOR_MAX
    if mod(cols, i) == 0
        d = abs(cols/i - OPT_DIM);
        if d < TH
            TH = d;
            Fcols = i;
        end
    end
end

lenRows = rows/Frows;
lenCols = cols/Fcols;
counter = 1;

for k = 1:Frows,
    
    % Get rows of the current tile
    f = and(posRows > (k-1)*lenRows-LIM, posRows < k*lenRows+LIM);
    posRows_aux = posRows(f);
    posCols_aux = posCols(f);
    weights_aux = weights(f);
    
    for l = 1:Fcols
        
        % Get columns of the current tile
        f = and(posCols_aux > (l-1)*lenCols-LIM, posCols_aux < l*lenCols+LIM);
        posRows_temp = posRows_aux(f);
        posCols_temp = posCols_aux(f);
        weights_temp = weights_aux(f);
        
        for i = (k-1)*lenRows+1:k*lenRows
            %tic
            for j = (l-1)*lenCols+1:l*lenCols
                
                fr = and(posRows_temp >= i-radius, posRows_temp <= i+radius);
                fc = and(posCols_temp >= j-radius, posCols_temp <= j+radius);
                f = and(fr, fc);
                
                r = posRows_temp(f) - i;
                c = posCols_temp(f) - j;
                d = sqrt(r.^2 + c.^2);
                
                cnt(i,j,1) = sum(exp(-d/SIGMA_SOFT));
                
                temp = weights_temp(f);
                cnt(i,j,2) = sum(temp);
                
                cnt(i,j,3) = sum(exp(-d/SIGMA_SOFT).*temp);
                
            end
            %toc
        end
        
        counter = counter + 1;
    end
end

% Clearing memory
clear fr fc f r c d posCols posCols_aux posCols_temp posRows posRows_aux posRows_temp temp weights weights_aux weights_temp


% === Mapping from Effective Data to 1:50 using Curve Fitting Tool to Estimate Curve ===
disp('Computing reconstructed images..');

sigma_map = zeros(rows,cols);

indicator = cnt(:,:,3);

lims = (0:0.02:1)*max(indicator(:))*TH_MAX;
nLims = length(lims);

if (weighting_struct.mec_weight_flag == 4) && (weighting_struct.dis_weight_flag == 1) && (weighting_struct.qps_weight_flag == 0) % SR2W410-Case
    if upscaling == 4, % Up4
        % Power Function with 2 Terms (a*x^b+c) and LAR-Robustness using cftool (tries to approximate the max curve)
        % Training6S15:
        alpha = 90.35;
        beta  = -0.5915;
        gamma = -9.346;
    elseif upscaling == 3, % Up3
        % Training6S15:
        alpha = 83.95;
        beta  = -0.1897;
        gamma = -39.6;
    else % Up2
        % Training6S15:
        alpha = -25.93;
        beta  = 0.1617;
        gamma = 48.63;
    end
else
    error('Not supported for this test..');
end

%avg_max_idx_chartup2 = [NaN,13,21,19,15,13,12,11,11,11,10,10,10,9,9,10,8,8,8,7,6,6,5,5,5,5,5,4,4,4,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]; %SR2W410-case (6S15-Training)
%avg_max_idx_chartup3 = [81,34,28,23,21,18,17,15,14,13,14,13,12,11,11,11,10,10,10,9,8,8,8,7,7,6,6,6,5,5,4,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]; %SR2W410-case (6S15-Training)
%avg_max_idx_chartup4 = [81,35,25,22,22,24,20,18,17,15,15,14,14,14,12,10,8,7,6,5,4,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]; %SR2W410-case (6S15-Training)


for iteraL = 1:nLims-1,
    idx = (indicator >= lims(iteraL)) & (indicator < lims(iteraL+1));
    
    if iteraL == nLims-1,
        idx = idx | (indicator >= lims(iteraL+1));
    end
    
    sigma_map(idx) = round(alpha*iteraL.^beta + gamma);
    
end

sigma_map(sigma_map < 1) = 1;
sigma_map(sigma_map > 100) = 100;

sigma_map = sigmas(sigma_map);


% === Build container ===

print_to_screen = 0;
profile = 'np';

container = zeros(rows, cols, nSigma,'uint8'); % MAGI-MEMORY-FIX

% MAGI-ACCELERATION
unique_sigmas = unique(sigma_map).';

%for i = 1:nSigma,
for i = 2*unique_sigmas,
    [~, aux] = BM3D(1, sr, sigmas(i), profile, print_to_screen);
    container(:,:,i) = uint8(aux*255); % MAGI-MEMORY-FIX
end


% === Reconstruction ===

img = zeros(rows,cols); % denoised image

for iteraY = 1:rows,
    for iteraX = 1:cols,
        img(iteraY,iteraX) = double(container(iteraY,iteraX,sigma_map(iteraY,iteraX)*2)); % MAGI-MEMORY-FIX
    end
end

dsr = img/255;

dbrsr_img = dsr;

% Deconvolution
psz = 16;
dsr = padarray(dsr,[psz psz],'replicate','both');

dbrsr_img_deconv = deconvlucy(dsr,psf,lucy_iter);

% Cropping
dbrsr_img_deconv = dbrsr_img_deconv(1+psz:end-psz,1+psz:end-psz,:);

