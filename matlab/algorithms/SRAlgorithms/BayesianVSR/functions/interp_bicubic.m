function vid_bic = interp_bicubic(vid_l, upscale)

N = length(vid_l);

for i = 1: N
    vid_bic{i} = imresize(vid_l{i}, upscale, 'bicubic');
    %vid_bic{i} = imresize(vid_l{i}, upscale, 'nearest');
end
