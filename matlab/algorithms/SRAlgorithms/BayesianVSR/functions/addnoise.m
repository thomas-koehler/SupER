function [ycbcr_l] = addnoise(ycbcr_l,m,v)

N = length(ycbcr_l);

for i = 1:N
    frame = ycbcr_l{i}(:,:,1);
    frame_noise = imnoise(frame,'gaussian',m,v);
    ycbcr_l{i}(:,:,1) = frame_noise;
end

%figure(2), imshow(ycbcr_l{1}(:,:,1));
