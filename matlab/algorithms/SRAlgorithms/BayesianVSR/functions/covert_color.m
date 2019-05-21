function [vid_ycbcr_l, vid_ycbcr_l_up] = covert_color(vid_rgb, upscale)

N = size(vid_rgb);
[m n] = size(vid_rgb{1});

for i = 1: N
    vid_ycbcr_l{i} = rgb2ycbcr(vid_rgb{i});
    vid_ycbcr_l_up{i} = imresize(vid_ycbcr_l{i}, upscale, 'bicubic');
end
