function SR = superresolve_irwsr(slidingWindow, magFactor)

    model = SRModel;
    model.magFactor = magFactor;
    model.psfWidth = 0.4;
    model.motionParams = slidingWindow.flowToReference;
    model.SR = imresize(slidingWindow.referenceFrame, magFactor);
    
    model.imagePrior = SRPrior('function', @btvPriorWeighted, 'gradient', @btvPriorWeighted_grad, 'weight', [], 'parameters', {size(model.SR), 1, 0.5, []});
    reweightedOptimParams = getReweightedOptimizationParams;
    SR = superresolve(slidingWindow.frames, model, 'reweightedSR', reweightedOptimParams);
        