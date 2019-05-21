function [vid_h_org, vid_l_bic] = load_video_mat(video,opt,part,param)

nFrames = opt.test_video.nFrame;
upscale = opt.res;

vid_h_org = [];
vid_l_bic = [];

for i = 1:nFrames
    tmp = video{i} ./ 255.0;
    if mod(size(tmp(:,:,1),1),upscale) ~= 0
        while mod(size(tmp(:,:,1),1),upscale) ~= 0
            tmp = tmp(1:end-1,:,:);
        end
    elseif mod(size(tmp(:,:,1),2),upscale) ~= 0
        while mod(size(tmp(:,:,1),2),upscale) ~= 0
            tmp = tmp(:,1:end-1,:);
        end
    end
    [M, N] = size(tmp(:,:,1));
    switch part
        case 1 % whole frame
            vid_h_org{i} = tmp;
        case 2 % no use
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