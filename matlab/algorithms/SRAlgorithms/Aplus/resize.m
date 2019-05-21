function imgs = resize(imgs, scale, method, verbose)

if nargin < 4
    verbose = 0;
end

h = [];
if verbose
    fprintf('Scaling %d images by %.2f (%s) ', numel(imgs), scale, method);
end

for i=1:numel(imgs)
    h = progress(h, i/numel(imgs), verbose);
    imgs{i} = imresize(imgs{i}, scale, method);
end
if verbose
    fprintf('\n');
end
