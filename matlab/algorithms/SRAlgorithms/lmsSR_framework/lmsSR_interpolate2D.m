function interp_img = lmsSR_interpolate2D(orig_img, upscaling, method)
%
% LMSSR_INTERPOLTE2D Resizes a single-channel image. Replicates the last value at right and bottom edges.
%    interp_img = LMSSR_INTERPOLATE2D(orig_img, upscaling, method)
%
% Parameters: orig_img    -   Single-channel image to be resized
%             upscaling   -   1x2 vector containing the upscaling factors for Y- and X-coordinates
%             method      -   'nearest' for nearest neighbor interpolation,
%                             'linear'  for bilinear interpolation,
%                             'spline'  for spline interpolation,
%                             'cubic'   for bicubic interpolation
%
% IMPORTANT NOTICE: In contrast to imresize(), does not change original samples! 
%                   Do not use for subsampling or 1-D interpolation!
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

[orig_height,orig_width,dye] = size(orig_img);

if upscaling(1) < 1 || upscaling(2) < 1,
    error('Subsampling is not supported as of now!');
elseif orig_height < 2 || orig_width < 2,
    error('1-D interpolation is not supported as of now!');
end

interp_img = zeros(orig_height*upscaling(1),orig_width*upscaling(2),dye);

% New Version
if upscaling(1) == 3,
    
    [interp_meshX,interp_meshY] = meshgrid(1:upscaling(2)*orig_width,1:upscaling(1)*orig_height); % Interpolated Meshgrid
    
    orig_meshX = interp_meshX(1:upscaling(1):end,1:upscaling(2):end);
    orig_meshY = interp_meshY(1:upscaling(1):end,1:upscaling(2):end);
    
    tmp_img = interp2(orig_meshX,orig_meshY,orig_img(:,:,1),interp_meshX,interp_meshY,method);
    
    interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,1) = tmp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,1);
else
    interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,1) = interp2(orig_img(:,:,1),log2(upscaling(1)),method);
end

% New Version
interp_img(:,:,1) = padarray(interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,1),[upscaling(1)-1,upscaling(2)-1],'replicate','post');

if dye == 3, % In the case of color
    
    % New Version
    interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,2) = interp2(orig_img(:,:,2),log2(upscaling(1)),method);
    interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,3) = interp2(orig_img(:,:,3),log2(upscaling(1)),method);
    
    % Fixing values at the bottom and right corners
    % New Version
    interp_img(:,:,2) = padarray(interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,2),[upscaling(1)-1,upscaling(2)-1],'replicate','post');
    interp_img(:,:,3) = padarray(interp_img(1:end-upscaling(1)+1,1:end-upscaling(2)+1,3),[upscaling(1)-1,upscaling(1)-1],'replicate','post');

end

