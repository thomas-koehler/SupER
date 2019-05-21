function [features] = collect(conf, imgs, scale, filters, verbose)

if nargin < 5
    verbose = 0;
end

num_of_imgs = numel(imgs);
feature_cell = cell(num_of_imgs, 1); % contains images' features
num_of_features = 0;

if verbose
    fprintf('Collecting features from %d image(s) ', num_of_imgs)
end
feature_size = [];

h = [];
for i = 1:num_of_imgs
    h = progress(h, i / num_of_imgs, verbose);
    sz = size(imgs{i});
    if verbose
        fprintf(' [%d x %d]', sz(1), sz(2));
    end
    
    F = extract(conf, imgs{i}, scale, filters);
    num_of_features = num_of_features + size(F, 2);
    feature_cell{i} = F;

    assert(isempty(feature_size) || feature_size == size(F, 1), ...
        'Inconsistent feature size!')
    feature_size = size(F, 1);
end
if verbose
    fprintf('\nExtracted %d features (size: %d)\n', num_of_features, feature_size);
end
clear imgs % to save memory
features = zeros([feature_size num_of_features], 'single');
offset = 0;
for i = 1:num_of_imgs
    F = feature_cell{i};
    N = size(F, 2); % number of features in current cell
    features(:, (1:N) + offset) = F;
    offset = offset + N;
end
