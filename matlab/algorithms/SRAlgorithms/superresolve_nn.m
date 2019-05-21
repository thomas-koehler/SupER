function SR = superresolve_nn(slidingWindow, magFactor)

    SR = imresize(slidingWindow.referenceFrame, magFactor, 'nearest');