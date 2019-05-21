function [lImFea] = extr_lIm_fea( lIm )

[nrow, ncol] = size(lIm);

lImFea = zeros([nrow, ncol, 4]);

% first order gradient filters
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
 
lImFea(:, :, 1) = conv2(lIm, hf1, 'same');
lImFea(:, :, 2) = conv2(lIm, vf1, 'same');

% second order gradient filters
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';
 
lImFea(:, :, 3) = conv2(lIm,hf2,'same');
lImFea(:, :, 4) = conv2(lIm,vf2,'same');

