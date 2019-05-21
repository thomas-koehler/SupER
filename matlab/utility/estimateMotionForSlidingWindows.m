% Perform  motion estimation across a set of images with respect to the
% reference frame.
function slidingWindows = estimateMotionForSlidingWindows(slidingWindows, estimateBackward, magFactor)

    % Perform motion estimation from/towards reference frame within the
    % current window.
    windowSize = size(slidingWindows.frames, 3);
    for frameIdx = 1 : windowSize

        % Estimate optical flow from the k-th frame towards the
        % reference frame in the current window.
        oflParams = [0.025, ...  % Regularization weight
            0.5, ...    % Downsample ratio
            20, ...     % Width of image pyramid coarsest level
            7, ...      % Number of outer fixed point iterations
            1, ...      % Number of inner fixed point iterations
            20];        % Number of SOR iterations
        if isequal(slidingWindows.frames(:,:,frameIdx), slidingWindows.referenceFrame)
            slidingWindows.flowToReference{frameIdx}.vx = zeros(size(slidingWindows.referenceFrame));
            slidingWindows.flowToReference{frameIdx}.vy = zeros(size(slidingWindows.referenceFrame));
        else
            [slidingWindows.flowToReference{frameIdx}.vx, slidingWindows.flowToReference{frameIdx}.vy] ...
                = Coarse2FineTwoFrames(slidingWindows.frames(:,:,frameIdx), slidingWindows.referenceFrame, oflParams);
            
			% Set flow towards reference frame.
            slidingWindows.flowToReference{frameIdx}.mvs(:,:,1) = slidingWindows.flowToReference{frameIdx}.vx;
            slidingWindows.flowToReference{frameIdx}.mvs(:,:,2) = slidingWindows.flowToReference{frameIdx}.vy;
            
            % SSD-Calculation
            slidingWindows.mec_confMap{frameIdx} = lmsSR_computeConfidenceMapForMotionVectors(slidingWindows.frames(:,:,frameIdx),slidingWindows.referenceFrame,slidingWindows.flowToReference{frameIdx}.mvs,[magFactor,magFactor]);
            
        end
        
        if estimateBackward
            % Estimate optical flow of the reference frame towards the
            % k-th frame in the current window.
            if isequal(slidingWindows.frames(:,:,frameIdx), slidingWindows.referenceFrame)
                slidingWindows.flowFromReference{frameIdx}.vx = zeros(size(slidingWindows.referenceFrame));
                slidingWindows.flowFromReference{frameIdx}.vy = zeros(size(slidingWindows.referenceFrame));
            else
                [slidingWindows.flowFromReference{frameIdx}.vx, slidingWindows.flowFromReference{frameIdx}.vy] ...
                    = Coarse2FineTwoFrames(slidingWindows.referenceFrame, slidingWindows.frames(:,:,frameIdx), oflParams);
                
                % Set flow towards reference.
                slidingWindows.flowFromReference{frameIdx}.mvs(:,:,1) = slidingWindows.flowFromReference{frameIdx}.vx;
                slidingWindows.flowFromReference{frameIdx}.mvs(:,:,2) = slidingWindows.flowFromReference{frameIdx}.vy;
                
                % Cross-Checking the Motion Vectors
                [slidingWindows.flowToReference{frameIdx}.mvs_xc,slidingWindows.flowFromReference{frameIdx}.mvs_xc] = lmsSR_computeMotionVectorXCheck(slidingWindows.flowToReference{frameIdx}.mvs,slidingWindows.flowFromReference{frameIdx}.mvs);
                
            end
        end
       
    end