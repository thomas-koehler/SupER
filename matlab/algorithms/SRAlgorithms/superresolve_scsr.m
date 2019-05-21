function sr_img = superresolve_scsr(slidingWindows, magFactor)

im_l_yuv  = slidingWindows.referenceFrame;
upscaling = magFactor;


% read test image
im_l_yuv = double(im2uint8(im_l_yuv));

% set parameters
lambda = 0.2;                   % sparsity regularization
overlap = 4;                    % the more overlap the better (patch size 5x5)
up_scale = upscaling; %2;       % scaling factor, depending on the trained dictionary
maxIter = 20;                   % if 0, do not use backprojection

psf{1} = fspecial('gaussian',5,0.8); % PSF for Up2
psf{2} = fspecial('gaussian',7,1.2); % PSF for Up3
psf{3} = fspecial('gaussian',9,1.6); % PSF for Up4
% psf{1} = fspecial('gaussian',3,0.75); % PSF for Up2
% psf{2} = fspecial('gaussian',3,1);    % PSF for Up3
% psf{3} = fspecial('gaussian',5,1);    % PSF for Up4

% load dictionary
basefolder = fileparts( mfilename( 'fullpath' ) ); % MAGI-ADAPT

load([basefolder,'/ScSR/Dictionary/MagiD_1024_0.15_5_s',num2str(up_scale),'.mat']);

% change color space, work on illuminance only
im_l_y = im_l_yuv(:,:,1,1); 

if size(im_l_yuv,3) == 3,
    im_l_u = im_l_yuv(:,:,2,1); 
    im_l_v = im_l_yuv(:,:,3,1);
end

% image super-resolution based on sparse representation
[im_h_y] = ScSR(im_l_y,up_scale,Dh,Dl,lambda,overlap); % MAGI-FIX: up_scale statt 2
[im_h_y] = backprojection(im_h_y,im_l_y,maxIter,psf{up_scale-1});

% upscale the chrominance simply by "bicubic" 
if size(im_l_yuv,3) == 3,
    im_h_u = lmsSR_interpolate2D(im_l_u,[up_scale up_scale],'cubic');
    im_h_v = lmsSR_interpolate2D(im_l_v,[up_scale up_scale],'cubic');
end

im_h_yuv(:,:,1) = im_h_y;

if size(im_l_yuv,3) == 3,
    im_h_yuv(:,:,2) = im_h_u;
    im_h_yuv(:,:,3) = im_h_v;
end

sr_img = im2double(uint8(im_h_yuv));

