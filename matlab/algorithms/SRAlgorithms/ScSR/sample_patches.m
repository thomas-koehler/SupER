function [HP, LP] = sample_patches(im, patch_size, patch_num, upscale)

if size(im, 3) == 3,
    hIm = rgb2gray(im);
else
    hIm = im;
end

% generate low resolution counter parts
lIm = imresize(hIm, 1/upscale, 'bicubic');
lIm = imresize(lIm, size(hIm), 'bicubic');
[nrow, ncol] = size(hIm);

x = randperm(nrow-2*patch_size-1) + patch_size;
y = randperm(ncol-2*patch_size-1) + patch_size;

[X,Y] = meshgrid(x,y);

xrow = X(:);
ycol = Y(:);

if patch_num < length(xrow),
    xrow = xrow(1:patch_num);
    ycol = ycol(1:patch_num);
end

patch_num = length(xrow);

hIm = double(hIm);
lIm = double(lIm);

H = zeros(patch_size^2,     length(xrow));
L = zeros(4*patch_size^2,   length(xrow));
 
% compute the first and second order gradients
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
 
lImG11 = conv2(lIm, hf1,'same');
lImG12 = conv2(lIm, vf1,'same');
 
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';
 
lImG21 = conv2(lIm,hf2,'same');
lImG22 = conv2(lIm,vf2,'same');

for ii = 1:patch_num,    
    row = xrow(ii);
    col = ycol(ii);
    
    Hpatch = hIm(row:row+patch_size-1,col:col+patch_size-1);
    
    Lpatch1 = lImG11(row:row+patch_size-1,col:col+patch_size-1);
    Lpatch2 = lImG12(row:row+patch_size-1,col:col+patch_size-1);
    Lpatch3 = lImG21(row:row+patch_size-1,col:col+patch_size-1);
    Lpatch4 = lImG22(row:row+patch_size-1,col:col+patch_size-1);
     
    Lpatch = [Lpatch1(:),Lpatch2(:),Lpatch3(:),Lpatch4(:)];
    Lpatch = Lpatch(:);
     
    HP(:,ii) = Hpatch(:)-mean(Hpatch(:));
    LP(:,ii) = Lpatch;
end
