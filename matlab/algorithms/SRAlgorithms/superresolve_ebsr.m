function [sr_img] = superresolve_ebsr(slidingWindows, magFactor)
%
% LMSSR_GENERATESRUSINGEBSR Performs a Single Image Super-Resolution (SISR) approach according to "Example-based Learning for Single-Image 
%                      Super-resolution". Supports GS/Y and RGB.
%    [sr_img] = LMSSR_GENERATESRUSINGEBSR(lr_img, upscaling)
%
% Parameters: lr_img          -   LR RGB or GS/Y image to be superresolved (height,width,dye)
%             upscaling       -   Scalar value containing the upscaling factor for both Y- and X-coordinates
%
% Important note: YUV images are also supported but yield bad results!
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

lr_img    = slidingWindows.referenceFrame;
upscaling = magFactor;


%Low = lr_ref_img;
%Low(:,:,2) = Low(:,:,1);
%Low(:,:,3) = Low(:,:,1);
%Low = im2uint8(Low);

if size(lr_img,3) == 3, % Color image case
    lr_img = lmsSR_convertYUV2RGB(lr_img);
end

sr_img = SuperresCode(lr_img,upscaling); % EXTERNAL CODE
sr_img = uint8(sr_img); % Required as output contains uint8 values

sr_img = im2double(sr_img);

if size(lr_img,3) == 3, % Color image case
    sr_img = lmsSR_convertRGB2YUV(sr_img);
end

