function SR = superresolve_sesr(slidingWindow, magFactor)
    
    currentDir = pwd;
    
    % Parameter settings for the desired magnification factor.
    opt = sr_init_opt(magFactor);
    
    % Save input image to make it accessible for SR algorithm.
    tempDir = pwd;
    mkdir(tempDir, 'temp');
    tempDir = [tempDir, '/temp'];
    filePath.dataPath    = tempDir;
    filePath.imgFileName = [char( datestr(now, 'dd-mmm-yyyy-HH-MM-SS-FFF') ), '.png'];
    imwrite(slidingWindow.referenceFrame, [filePath.dataPath , '/' filePath.imgFileName]);
    
    % Perform super-resolution.
    cd('../algorithms/SRAlgorithms/SelfExSR');
    SR = sr_demo(filePath, opt);
    
    delete([filePath.dataPath , '/' filePath.imgFileName]);
    cd(currentDir);