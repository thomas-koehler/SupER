function SR = superresolve_l1btv(slidingWindow, magFactor)

    model = SRModel;
    model.magFactor = magFactor;
    model.psfWidth = 0.4;
    model.motionParams = slidingWindow.flowToReference;
    model.SR = imresize(slidingWindow.referenceFrame, magFactor);
    
    model.imagePrior = SRPrior('function', @btvPrior, 'gradient', @btvPrior_grad, 'weight', 1e-2, 'parameters', {size(model.SR), 1, 0.5});
    model.errorModel = 'l1NormErrorModel';
    SR = superresolve(slidingWindow.frames, model, 'map');
        