function [D] = compute_diffusion_coefficient(I)

alpha = 5.0;
beta = 0.5;

wSize = 5;
sigma = wSize/6;

gI = imfilter(I, fspecial('gaussian', [wSize wSize], sigma),'replicate');
mask = [-1 0 1];
Ix = imfilter(gI, mask, 'replicate');
Iy = imfilter(gI, mask', 'replicate');

norm = sqrt(Ix.^2 + Iy.^2);

D = max(1e-06, exp(-alpha*norm.^beta));

end

