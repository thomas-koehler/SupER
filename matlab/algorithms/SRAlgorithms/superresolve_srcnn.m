function SR = superresolve_srcnn(slidingWindow, magFactor)

    % Select the desired model
    if magFactor == 2
        model = ['model',filesep,'9-5-5(ImageNet)',filesep,'x2.mat'];
    elseif magFactor == 3
        model = ['model',filesep,'9-5-5(ImageNet)',filesep,'x3.mat'];
    elseif magFactor == 4
        model = ['model',filesep,'9-5-5(ImageNet)',filesep,'x4.mat'];
    else
        error('Magnification factor not supported');
    end
    
    % Apply CNN with the selected model.
    SR = SRCNN(model, imresize(slidingWindow.referenceFrame, magFactor));