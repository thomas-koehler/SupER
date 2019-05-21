function [warped_posX, warped_posY] = lmsSR_warpImgGridLocalTrans(img_rows, img_cols, transMotion)
%
% LMSSR_WARPIMGGRIDLOCALTRANS Computes the XY-position grid of an image for local translation. 
%    [warped_posX, warped_posY] = LMSSR_WARPIMGGRIDLOCALTRANS(img_rows, img_cols, transMotion)
%
% Parameters: img_rows      -   Number of rows in the image
%             img_cols      -   Number of columns in the image
%             transMotion   -   Local translation motion vectors (X,Y)
%
% Author: Michel Bätz (LMS)
%
% See also: lmsSR_framework
%

% Create X-Y-Position Grids
[orig_posX,orig_posY] = meshgrid(1:img_cols,1:img_rows);

% Local Translational Motion Compensation
warped_posX = orig_posX + transMotion(:,:,1);
warped_posY = orig_posY + transMotion(:,:,2);

