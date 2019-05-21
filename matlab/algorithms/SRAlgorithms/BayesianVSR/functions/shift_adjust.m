function [img_sh] = shift_adjust(img,upscale,dir)

N = length(img);

if upscale == 2
    shift = 0.5;
elseif upscale == 3
    shift = 1;
elseif upscale == 4
    shift = 1.5;
end

if size(img{1},3) == 3
    [m n] = size(img{1}(:,:,1));
else
    [m,n] = size(img{1});
end
[x y] = meshgrid(1:n,1:m);

if dir == 1
    x1 = x+shift;
    y1 = y+shift;
else % dir == -1
    x1 = x-shift;
    y1 = y-shift;
end

x1(x1 <= 1) = 1;
y1(y1 <= 1) = 1;
x1(x1 >= n) = n;
y1(y1 >= m) = m;

if size(img{1},3) == 3
    for j = 1:N
        for i = 1:3
            img_sh{j}(:,:,i) = interp2(x,y,img{j}(:,:,i),x1,y1);
        end
    end
else
    for j = 1:N
        img_sh{j}(:,:) = interp2(x,y,img{j}(:,:),x1,y1);
    end    
end