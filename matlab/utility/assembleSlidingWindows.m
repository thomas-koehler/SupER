% Extract WINDOWSIZE consecutive frames at position SLIDINGWINDOWIDX from a
% given image sequence.
function slidingWindow = assembleSlidingWindows(I, startFrame, windowSize, slidingWindowIdx)

    % Get the index of the reference frame for the current sliding window.
    refFrameIdx = startFrame + slidingWindowIdx - 1;

    % Extract sliding window from the given input sequence.
    slidingWindow.frames = I(:,:,(refFrameIdx - floor(windowSize / 2)):(refFrameIdx + floor(windowSize / 2)));
    % Capture reference frame for the current window.
    slidingWindow.referenceFrame = I(:,:,refFrameIdx);

