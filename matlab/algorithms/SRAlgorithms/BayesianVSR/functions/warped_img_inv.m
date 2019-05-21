function FtI = warped_img_inv(I,u,v)

[M,N] = size(I);

% Stack the motion field into vector
vectors = zeros(length(xPos),2);
vectors(:,1) = u(sub2ind(size(u),yPos,xPos));
vectors(:,2) = v(sub2ind(size(u),yPos,xPos));

% Calculate frame2to1
[xPosv, yPosv] = meshgrid(1:1:n_size(2),1:1:n_size(1));
% vectors_full is the full size motion field
vectors_full = zeros(n_size(1),n_size(2),2);
vectors_full(:,:,1) = u;
vectors_full(:,:,2) = v;

xPosv = xPosv+vectors_full(:,:,1);
yPosv = yPosv+vectors_full(:,:,2);
xPosv = reshape(xPosv,n_size(1),n_size(2));
yPosv = reshape(yPosv,n_size(1),n_size(2));

xPosv(xPosv <= 1) = 1;
yPosv(yPosv <= 1) = 1;
xPosv(xPosv >= n_size(2)) = n_size(2);
yPosv(yPosv >= n_size(1)) = n_size(1);

FtI = interp2(I,xPosv,yPosv,'cubic');