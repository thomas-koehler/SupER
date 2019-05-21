function [vid_rgb] = convert_y2rgb(vid_y, vid_ycbcr)

N = length(vid_y);

for i = 1:N
    vid_ycbcr{i}(:,:,1) = vid_y{i};
    vid_rgb{i} = ycbcr2rgb(vid_ycbcr{i});
end
