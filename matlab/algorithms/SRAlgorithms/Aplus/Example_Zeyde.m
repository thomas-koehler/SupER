%% Basic stuff
clear; 

p = pwd;
addpath(fullfile(p, 'ksvdbox')) % K-SVD dictionary training algorithm
addpath(fullfile(p, 'ompbox')) % Orthogonal Matching Pursuit algorithm
mat_file = 'conf.mat';

% %% Simulation settings
% conf.scale = 3; % scale-up factor
% conf.level = 1; % # of scale-ups to perform
% conf.window = [3 3]; % low-res. window size
% conf.border = [1 1]; % border of the image (to ignore)
% 
% % High-pass filters for feature extraction (defined for upsampled low-res.)
% conf.upsample_factor = 3; % upsample low-res. into mid-res.
% O = zeros(1, conf.upsample_factor-1);
% G = [1 O -1]; % Gradient
% L = [1 O -2 O 1]/2; % Laplacian
% conf.filters = {G, G.', L, L.'}; % 2D versions
% conf.interpolate_kernel = 'bicubic';
% 
% conf.overlap = [1 1]; % partial overlap (for faster training)
% conf = learn_dict(conf, load_images(...
%     glob('CVPR08-SR/Data/Training', '*.bmp')), 1000);
% conf.overlap = conf.window - [1 1]; % full overlap scheme (for better reconstruction)
% save(mat_file, 'conf');

%% Reconstruct
load(mat_file, 'conf');
input_dir = 'TestImages'; % Directory with input images
pattern = '*.bmp'; % Pattern to process
conf.filenames = glob(input_dir, pattern); % Cell array
conf.desc = {'Original', 'Bicubic', 'Yang et. al.', 'Our algorithm'};
conf.results = {};
t = cputime;
for i = 1:numel(conf.filenames)
    f = conf.filenames{i};
    [p, n, x] = fileparts(f);
    img = load_images({f}); 
    sz = size(img{1});
    fprintf('%d/%d\t"%s" [%d x %d]\n', i, numel(conf.filenames), f, sz(1), sz(2));
    
    img = modcrop(img, conf.scale^conf.level);
    low = resize(img, 1/conf.scale^conf.level, conf.interpolate_kernel);

    interpolated = resize(low, conf.scale^conf.level, conf.interpolate_kernel);    
    [res] = scaleup_Zeyde(conf, low);
    %Y = yima(low{1});
    Y = res{1};
    result = cat(3, img{1}, interpolated{1}, Y, res{1});
    result = shave(uint8(result * 255), conf.border * conf.scale);
    conf.results{i} = {};
    for j = 1:numel(conf.desc)
        conf.results{i}{j} = fullfile(p, 'results', [n sprintf('[%d-%s]', j, conf.desc{j}) x]);
        imwrite(result(:, :, j), conf.results{i}{j});
    end
    
    conf.filenames{i} = f;
end
conf.duration = cputime - t;

%% Test performance
conf.result_dir = qmkdir(['Results-' datestr(now, 'YYYY-mm-dd_HH-MM-SS')]);
run_comparison(conf);
