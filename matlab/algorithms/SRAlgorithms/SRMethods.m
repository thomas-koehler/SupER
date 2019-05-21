function srMethods = SRMethods

    srMethods = [...
        % Kim and Kwon, Single-Image Super-Resolution Using Sparse
        % Regression and Natural Image Prior
        SRMethodConfig('ebsr', 'sisr', false, false, 'topLeft');   % No motion estimation
        
        % Yang et al., Image super-resolution via sparse representation
        SRMethodConfig('scsr', 'sisr', false, false, 'topLeft');   % No motion estimation
        
        % Salvador and Perez-Pellitero, Naive Bayes Super-Resolution Forest
        SRMethodConfig('nbsrf', 'sisr', false, false);  % No motion estimation
        
        % Kappeler et al., Video Super-Resolution With Convolutional Neural
        % Networks
        SRMethodConfig('vsrnet', 'mfsr', false, false); % No motion estimation
        
        % Non-uniform interpolation based super-resolution (NUISR)
        SRMethodConfig('nuisr', 'mfsr', true, true, 'topLeft');   % Forward/backward motion 
        
        % Baetz et al., Multi-Image Super-Resolution Using a Dual Weighting
        % Scheme Based on Voronoi Tessellation
        SRMethodConfig('wnuisr', 'mfsr', true, true, 'topLeft');   % Forward/backward motion
        
        % Baetz et al., Hybrid Super-Resolution Combining Example-based
        % Single-Image and Interpolation-based Multi-Image Reconstruction
        % Approaches
        SRMethodConfig('hysr', 'mfsr', true, true, 'topLeft');     % Forward/backward motion 
        
        % Baetz et al., Multi-image super-resolution using a locally
        % adaptive denoising-based refinement
        SRMethodConfig('dbrsr', 'mfsr', true, true, 'topLeft');    % Forward/backward motion 
        
        % Ma et al., Handling Motion Blur in Multi-Frame Super-Resolution
        SRMethodConfig('srb', 'mfsr', false, false, 'topLeft');    % No motion estimation 
        
        % Farsiu et al., Fast and robust multiframe super resolution
        SRMethodConfig('l1btv', 'mfsr', true, false);   % Forward motion estimation 
        
        % Koehler et al., Robust multi-frame super-resolution employing
        % iteratively re-weighted minimization
        SRMethodConfig('irwsr', 'mfsr', true, false);   % Forward motion estimation    
        
        % Nearest-neighbour interpolation
        SRMethodConfig('nn', 'sisr', false, false);     % No motion estimation 
        
        % Bicubic interpolation
        SRMethodConfig('bicubic', 'sisr', false, false);% No motion estimation 
        
        % Liu et al., On Bayesian Adaptive Video Super Resolution
        SRMethodConfig('bvsr', 'mfsr', false, false);   % No motion estimation 
        
        % Dong et al., Learning a Deep Convolutional Network for Image
        % Super-Resolution
        SRMethodConfig('srcnn', 'sisr', false, false);  % No motion estimation  
        
        % Zeng and Yang, A Robust Multiframe Super-Resolution Algorithm
        % based on Half-Quadratic Estimation with Modified BTV
        % Regularization
        SRMethodConfig('bepsr', 'mfsr', true, false);   % Forward motion estimation 
        
        % Huang et al., Single Image Super-Resolution from Transformed
        % Self-Exemplars
        SRMethodConfig('sesr', 'sisr', false, false);   % No motion estimation 
        
        % Kim et al., Deeply-Recursive Convolutional Network for Image
        % Super-Resolution
        SRMethodConfig('drcn', 'sisr', false, false);   % No motion estimation 
        
        % Kim et al., Accurate Image Super-Resolution Using Very Deep
        % Convolutional Networks
        SRMethodConfig('vdsr', 'sisr', false, false);   % No motion estimation 
        
        % Timofte et al., A+: Adjusted Anchored Neighborhood Regression for
        % Fast Super-Resolution
        SRMethodConfig('aplus', 'sisr', false, false);  % No motion estimation
    ];