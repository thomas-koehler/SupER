function [Xh, Xl] = rnd_smp_patch(img_path, type, patch_size, num_patch, upscale)

img_dir = dir(fullfile(img_path, type));

Xh = [];
Xl = [];

img_num = length(img_dir);
nper_img = zeros(1, img_num);

for ii = 1:length(img_dir),
    im = imread(fullfile(img_path, img_dir(ii).name));
    nper_img(ii) = prod(size(im));
end

nper_img = floor(nper_img*num_patch/sum(nper_img));

for ii = 1:img_num,
    patch_num = nper_img(ii);
    im = imread(fullfile(img_path, img_dir(ii).name));
    [H, L] = sample_patches(im, patch_size, patch_num, upscale);
    Xh = [Xh, H];
    Xl = [Xl, L];
end

patch_path = ['Training/rnd_patches_' num2str(patch_size) '_' num2str(num_patch) '_s' num2str(upscale) '.mat'];
save(patch_path, 'Xh', 'Xl');