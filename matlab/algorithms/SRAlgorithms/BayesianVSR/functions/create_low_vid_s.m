function vid_l = create_low_vid_s(vid_h_orig,h_2d,opt)

vid_l = [];
frame = zeros(opt.m, opt.n, 3);
nFrames = opt.nFrames;

for i = 1:nFrames
    frame_org = vid_h_orig{i};
    blurred_r = cconv2d(h_2d,frame_org(:,:,1));
    blurred_g = cconv2d(h_2d,frame_org(:,:,2));
    blurred_b = cconv2d(h_2d,frame_org(:,:,3));
    
    frame(:,:,1) = down_sample(blurred_r,opt.res);
    frame(:,:,2) = down_sample(blurred_g,opt.res);
    frame(:,:,3) = down_sample(blurred_b,opt.res);
    
    %frame_noise = imnoise(frame,'gaussian',opt.noisem,opt.noisev);
    vid_l{i} = frame;
end
