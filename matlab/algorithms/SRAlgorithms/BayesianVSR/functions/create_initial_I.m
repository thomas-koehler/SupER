function y = create_initial_I(J, upscale, h_2d)

N = length(J);
y = [];

for i = 1:N
    if upscale == 2
        h = [0.25 0.5 0.25; 0.5 1 0.5; 0.25 0.5 0.25];
        tmp = up_sample(J{i},upscale);
        y{i} = cconv2d(h, tmp);
    else
        y{i} = imresize(J{i},upscale,'bilinear');
    end
end
