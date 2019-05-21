function srMethod = SRMethodConfig(srMethodName, type, estimateMotion, estimateMotionBackward, pixelSampling)
    
    if nargin < 5
        pixelSampling = 'center';
    end
    
    % Name of the super-resolution method in plain text.
    srMethod.name = srMethodName;
    
    srMethod.type = type;
    
    % Flag to enable motion estimation.
    % 'false': No motion estimation
    % 'true': Perform motion estimation (for multi-frame algorithms only)
    srMethod.estimateMotion = estimateMotion;
    
    % Flag to enable motion estimation in backward direction
    % 'false': No motion estimation
    % 'true: Perform motion estimation in backward direction (required for
    %        some multi-frame algorithms only)
    srMethod.estimateMotionBackward = estimateMotionBackward;
	
	% Pixel sampling scheme. 'center' (default) samples pixels at the center
	% point, whereas 'topLeft' samples pixels at the top-left corner.
	srMethod.pixelSampling = pixelSampling;