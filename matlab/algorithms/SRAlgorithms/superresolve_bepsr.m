function SR = superresolve_bepsr(slidingWindow, magFactor)

    model = SRModel;
    model.magFactor = magFactor;
    model.psfWidth = 0.4;
    model.motionParams = slidingWindow.flowToReference;
    model.SR = imresize(slidingWindow.referenceFrame, magFactor);
    
    model.imagePrior = SRPrior('function', @bepPrior, 'gradient', @bepPrior_grad, 'weight', 1e-2, 'parameters', {size(model.SR), 1, 0.5, 0.025});
    SR = superresolve(slidingWindow.frames, model, 'bep');
        