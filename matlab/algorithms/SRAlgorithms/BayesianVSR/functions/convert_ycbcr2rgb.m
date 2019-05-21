function [vid_rgb] = convert_ycbcr2rgb(vid_ycbcr)

N = length(vid_ycbcr);

for i = 1:N
    vid_rgb{i} = ycbcr2rgb(vid_ycbcr{i});
end
