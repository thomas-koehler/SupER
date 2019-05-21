function res = calc_PeakSNR(f, g)
F = im2double(imread(f)); % original
G = im2double(imread(g)); % distorted
E = F - G; % error signal
N = numel(E); % Assume the original signal is at peak (|F|=1)
res = 10*log10( N / sum(E(:).^2) );
