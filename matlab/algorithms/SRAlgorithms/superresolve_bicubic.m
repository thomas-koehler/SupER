function SR = superresolve_bicubic(slidingWindow, magFactor)

    SR = imresize(slidingWindow.referenceFrame, magFactor, 'bicubic');
    