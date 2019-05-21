function [vid_ycbcr] = convert_rgb2ycbcr(vid_rgb)

N = length(vid_rgb);

for i = 1: N
    vid_ycbcr{i} = rgb2ycbcr(vid_rgb{i});
end
