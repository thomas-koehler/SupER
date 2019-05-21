function qm = qualityMeasures

    qm = {...
        % Peak-signal-to-noise ratio
        'psnr';
        
        % Structural similarity index
        'ssim';
        
        % Multiscale structural similarity index
        'msssim';
        
        % Information fidelity criterion
        'ifc';
        
        % Spectral & spatial measure of local perceived sharpness
        's3';
        
        % Blind/Referenceless image spatial quality evaluator
        'brisque';
        
        % Spatial/spectral entropy-based quality index
        'sseq';
        
        % Naturalness image quality evaluator
        'niqe';
        
        % No-Reference quality metric for single-image super-resolution
        'srm';
        
        % Learned perceptual image patch similarity
        'lpips';
    };