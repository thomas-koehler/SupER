function [vid_h_org, vid_l_bic] = load_video(dirFile,nFrames,upscale,part,param)

vid_h_org = [];
vid_l_bic = [];

for i = 1:nFrames
    filename = sprintf('original/Frame %03d.png', i);
    fullname = strcat(dirFile,filename);
    tmp = im2double(imread(fullname,'png'));
    [M N] = size(tmp(:,:,1));
    switch part
        case 1 
            vid_h_org{i} = tmp;
        case 2 
            vid_h_org{i} = imresize(tmp, 1/2);
        case 3 % half x half (288x352)
            vid_h_org{i} = tmp(1:M/2,1:N/2,:);
        case 4 % quarter x quarter (144x176)
            vid_h_org{i} = tmp(1:M/4,1:N/4,:);
        case 5 % 64x64
            vid_h_org{i} = tmp(65:128,1:64,:);
        case 6 % 32x64
            vid_h_org{i} = tmp(65:96,1:64,:);
    end
    vid_l_bic{i} = imresize(vid_h_org{i}, 1/upscale);
end

if param.SHOW_IMAGE
    figure(1), imshow(vid_h_org{1}); title('original (frame1)');
end