function [srImage, timeME, timeSR] = runSRAlgorithm(I, groundTruth, magFactor, startReferenceFrame, numberOfFrames, slidingWindowIdx, srMethodIdx)
    
    % Time measurements for motion estimation and SR reconstruction.
    timeME = NaN;
    timeSR = NaN;

    % Extract the desired sliding window.
    slidingWindow = assembleSlidingWindows(I, startReferenceFrame, numberOfFrames, slidingWindowIdx);
    slidingWindow_groundTruth = assembleSlidingWindows(groundTruth, startReferenceFrame, numberOfFrames, slidingWindowIdx);
    
    if srMethodIdx == 0
        % Return the ground truth image.
        srImage.groundTruth = slidingWindow_groundTruth.referenceFrame;
        return;
    end
    
    % Get name and configuration for the desired SR method.
    srMethodsArray = SRMethods;
    srMethod = srMethodsArray(srMethodIdx);
    
    % Motion estimation for sliding window if desired.
    if srMethod.estimateMotion
        tME = tic;
        slidingWindow = estimateMotionForSlidingWindows(slidingWindow, srMethod.estimateMotionBackward, magFactor);
        timeME = toc(tME);
    end

    % SR for current sliding window with the desired method.
    tSR = tic;
    srImage.(srMethod.name) = callSRMethod(slidingWindow, magFactor, srMethod);
    timeSR = toc(tSR);