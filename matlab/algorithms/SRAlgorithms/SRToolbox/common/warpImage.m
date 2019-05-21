function warpI = warpImage(I, motion)

    if isstruct(motion)
        
        % Warping using displacement vector field.
        [M, N] = size(I);
        [x, y] = meshgrid(1:N, 1:M);
        % Interpolate warped image.
        warpI = interp2(x, y, I, x - motion.vx, y - motion.vy, 'bicubic');
        % Set NaN values in the warped image to zero.
        I = find( isnan(warpI) );
        warpI(I) = zeros(size(I));
        
    else
        
        % Warping using homography given as 3x3 matrix.
        tform = maketform('projective2D', motion');
        warpI = imtransform(I, tform, 'XData', [1 size(I,2)], 'YData', [1 size(I,1)]);
        
    end

end

