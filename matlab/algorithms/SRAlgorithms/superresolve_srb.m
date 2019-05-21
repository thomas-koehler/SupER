function SR = superresolve_srb(slidingWindow, magFactor)

    % Prepare folder for temp files (intermediate results of the
    % algorithm.)
    foldername = char( datestr(now, 'dd-mmm-yyyy-HH-MM-SS-FFF') );
    tempDir = userpath;
    tempDir = tempDir(1:end-1);
    mkdir(tempDir, foldername);
    inputFolder = [tempDir, '/', foldername];
    
    % Save input data as 3-channel color images.
    LRFrames = slidingWindow.frames;
    for k = 1:size(LRFrames, 3)
        I(:,:,1) = LRFrames(:,:,k); 
        I(:,:,2) = LRFrames(:,:,k); 
        I(:,:,3) = LRFrames(:,:,k);
        imwrite(I, [inputFolder, '/', sprintf('x_%04i.png', k)]);
    end
    
    % Set parameters
    parameters.epsilon_recon = 0.001; % the smaller the epsilon, the more cartoon-like result
    parameters.temporalRadius = round( (size(LRFrames,3) - 1) / 2 ); % use 2*temporalRadius+1 frames to super-resolve one frame
    parameters.blurKerRadius = 31; %51; %round(6 * 0.4 * magFactor);
    if mod(parameters.blurKerRadius, 2) == 0
        parameters.blurKerRadius = parameters.blurKerRadius + 1;
    end
    parameters.blurKerSmoothness = 5;
    parameters.dataTermScale_recon = 6;
    parameters.killSmoothFrames = round( size(LRFrames,3) / 4 );
    parameters.numOuterIters = 3;
    parameters.numIRLSIters_recon = 2;
    parameters.initGaussSigma = 0.4 * magFactor;
    parameters.celiuOFlowAlpha = 0.1; %0.02;
    parameters.scaleFactor = magFactor;
    parameters.bEstimateOpticalFlow = true;
    parameters.bEstimateKernel = true;
    parameters.eta = 0.1; %0.02;

    if inputFolder(end) ~= '\'
        inputFolder = [inputFolder,'\'];
    end

    parameters.totalFrames = length(srb_img_dir(inputFolder));

    if parameters.bEstimateKernel
        resultFolder = sprintf('%sresults\\withKerEst', inputFolder);
        strInfo = sprintf(...
            'result[tr=%03d,kr=%03d,ks=%04.1f,dts=%03d,kill=%02d,iter[%02d,%02d],sig0=%2.1f,a=%5.3f]', ...
            parameters.temporalRadius, ...      % tr
            parameters.blurKerRadius, ...       % kr
            parameters.blurKerSmoothness, ...   % ks
            parameters.dataTermScale_recon, ... % dts
            parameters.killSmoothFrames, ...    % kill
            parameters.numOuterIters, ...       % iter[outerIters, ...]
            parameters.numIRLSIters_recon, ...  % iter[..., IRLSIters_recon]
            parameters.initGaussSigma, ...      % sig0
            parameters.celiuOFlowAlpha);        % a
    else
        resultFolder = sprintf('%sresults\\withoutKerEst', inputFolder);
        strInfo = sprintf('result[tr=%03d,dts=%03d,kill=%02d,iter[%02d,%02d],sig0=%2.1f,a=%5.3f]', ...
            parameters.temporalRadius, ...      % tr
            parameters.dataTermScale_recon, ... % dts
            parameters.killSmoothFrames,...     % kill
            parameters.numOuterIters, ...       % iter[outerIters, ...]
            parameters.numIRLSIters_recon, ...  % iter[..., IRLSIters_recon]
            parameters.initGaussSigma, ...      % sig0
            parameters.celiuOFlowAlpha);        % a
    end

    if ~exist(resultFolder,'dir')
        mkdir(resultFolder);
    end

    resultFolder = sprintf('%s\\%s\\', resultFolder, strInfo);

    if ~exist(resultFolder,'dir')
        mkdir(resultFolder);
    end

    parameters.inputFolder  = inputFolder ;
    parameters.resultFolder = resultFolder;

    %---------------------------------------------------------------------------------------------------------

    global iItersInIRLS;
    global imgGroundTruth;

    iItersInIRLS = 0;

    if ~isfield(parameters, 'imgGroundTruth')
        imgGroundTruth = [];
    else
        imgGroundTruth = parameters.imgGroundTruth;
    end

    %---------------------------------------------------------------------------------------------------------

    stream = RandStream.getGlobalStream; 
    reset(stream);  %% for DEBUGGING, because MSAC uses random selection

    % Load frames: vecImgJ for the ii-th frame in the input folder
    temporalRadius = parameters.temporalRadius;
    ii = parameters.temporalRadius + 1;
    [vecImgJ, idx0] = srb_loadframes_for_frame(ii, inputFolder, temporalRadius, false, false);
    
    % Super-resolution for the selected reference frame.
    parameters.currentFrame = ii;
    [SR,~,~] = srb_multiframeSR_select(vecImgJ, idx0, parameters); 

    % Delete folder with temp files.
    rmdir(inputFolder, 's');