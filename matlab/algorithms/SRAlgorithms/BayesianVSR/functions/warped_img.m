function FI = warped_img(I,u,v)

[M,N] = size(I);

% Calculate frame2to1
[xPosv, yPosv] = meshgrid(1:N,1:M);
FI = interp2(xPosv,yPosv,I,xPosv - u,yPosv - v,'bicubic');
I = find( isnan(FI) );
FI(I) = zeros(size(I));