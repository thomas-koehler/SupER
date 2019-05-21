function [SR, varargout] = superresolve(LRImages, model, method, varargin)
%SUPERRESOLVE Multi-frame super-resolution image reconstruction
%   SUPERRESOLVE is the interface function for all super-resolution algorithms
%	in this Matlab toolbox. This function takes a sequence of low-resolution 
%	images as input and reconstructs a new image of improved spatial resolution 
%	in terms of pixels.
%
%   X = SUPERRESOLVE(Y, M, METHOD) super-resolves low-resolution data Y
%   with the underlying model parameters M using the specified algorithm
%   METHOD.
%
%   Different super-resolution algorithms are supported:
%
%   ----------------------------------------------------------------------
%   Maximum a-posteriori (MAP) approach:
%   ----------------------------------------------------------------------
%       X = SUPERRESOLVE(Y, MODEL, 'map', M) super-resolves an image
%       sequence encoded as 3-D array Y using the model parameters M 
%       (encoding subpixel motion, photometric parameters and static 
%       imaging parameters, i.e. magnification factor and camera point 
%       spread function) used for super-resolution, see
%       SRModel.
%
%       X = SUPERRESOLVE(..., PARAMS) controls numerical optimization with
%       additional parameters encoded in the PARAMS structure, see also
%       SRSolverParams.
%
%   ----------------------------------------------------------------------
%   Maximum a-posteriori super-resolution with quality self-assessment
%   (MAP-QSA)
%   ----------------------------------------------------------------------
%       X = SUPERRESOLVE(Y, MODEL, 'mapqsa', M, WRANGE, QFUNC) 
%       super-resolves an image sequence encoded as 3-D array Y using the 
%       model parameters M (encoding subpixel motion, photometric 
%       parameters and static imaging parameters, i.e. magnification factor 
%       and camera point spread function) used for super-resolution, see
%       SRModel. The regularization weight for the image prior is
%       automatically selected within the range WRANGE by maximizing the
%       quality index given by the function handle QFUNC.
%
%       X = SUPERRESOLVE(..., PARAMS) controls numerical optimization with
%       additional parameters encoded in the PARAMS structure, see also
%       SRSolverParams.
%
%       Reference:
%       Thomas Köhler, Alexander Brost, Katja Mogalle, Qianyi Zhang, 
%       Christiane Köhler, Georg Michelson, Joachim Hornegger and Ralf P.
%       Tornow, Multi-Frame Super-Resolution with Quality Self-Assessment 
%       for Retinal Fundus Videos, MICCAI 2014
%       
%   ----------------------------------------------------------------------
%   Multi-sensor super-resolution approach (for hybrid 3-D range imaging):
%   ----------------------------------------------------------------------
%       [X, MODEL] = SUPERRESOLVE(Y, MODEL, 'multisens', M) super-resolves
%       low-resolution data Y in a multi-sensor framework. That means
%       subpixel displacement fields required for super-resolution are
%       estimated on complementary high-resolution data (e.g. color images) 
%       and transferred to low-resolution data (e.g. range images) based on
%       sensor data fusion. The transformed model parameters determined by
%       this approach are returned as additional output parameter.
%
%       Reference:
%       Thomas Köhler, Sven Haase, Sebastian Bauer et al., ToF Meets RGB:
%       Novel Multi-Sensor Super-Resolution For Hybrid 3-D Endoscopy,
%       MICCAI 2013
%
%   ----------------------------------------------------------------------
%   Iteratively re-weighted least squares (IRLS) approach:
%   ----------------------------------------------------------------------
%       X = SUPERRESOLVE(Y, MODEL, 'irls', WF, M) uses iteratively 
%       re-weighted least squares estimation (IRLS) to obtain a
%       super-resolved image X from the low-resolution frames encodes as 
%       3-D array Y. WF denotes a weight function for IRLS with interface W
%       = WF(R) where R is the residual error of super-resolution
%       reconstruction and W are the weights derived from R.
%
%       X = SUPERRESOLVE(..., PARAMS) controls numerical optimization with
%       additional parameters encoded in the PARAMS structure, see also
%       SRSolverParams.
%
%       Reference:
%       Thomas Köhler, Sven Haase, Sebastian Bauer et al., Outlier
%       Detection For Multi-Sensor Super-Resolution in Hybrid 3-D
%       Endoscopy, BVM 2014
%
%   ----------------------------------------------------------------------
%   Guided super-resolution (GSR):
%   ----------------------------------------------------------------------
%       [X, Q] = SUPERRESOLVE(Y, M_Y, 'guidedsr', P, M_P, WF) uses guided 
%       super-resolution to super-resolve input images Y according to the 
%       model M_Y as well as guidance images P according to the model M_P. 
%       This algorithms uses the weight function WF for IRLS optimization. 
%       X and Q are the super-resolved input and guidance images, 
%       respectively.
%
%       [X, Q] = SUPERRESOLVE(..., RAD, EPS, LAMBDA) uses the window radius 
%       RAD (default: 1), regularization parameter EPS (default: 1e-4) and 
%       weight LAMBDA (default: 0.5) for interdependence regularization
%       based on guided filtering.
%       
%       [X, Q] = SUPERRESOLVE(..., PARAMS) controls numerical optimization 
%       with additional parameters encoded in the PARAMS structure, see 
%       also SRSolverParams.
%       
%       Reference:
%       Florin C. Ghesu, Thomas Köhler, Sven Haase and Joachim Hornegger, 
%       "Guided Image Super-Resolution: A New Technique for Photogeometric
%       Super-Resolution in Hybrid 3-D Range Imaging", GCPR 2014
%
%	Multi-channel super-resolution using locally linear regression (LLR)
%   ----------------------------------------------------------------------
%       X = SUPERRESOLVE(Y, MODEL, 'llr', MU, R, EPS) 
%       reconstructs a super-resolved multi-channel image X from 
%       low-resolution multi-channel images Y using the LLR model with 
%       inter-channel regularization weight MU, filter radius R and 
%       regularization weight EPS for the filter coefficients.
%
%       Reference:
%       Thomas Köhler, Johannes Jordan, Andreas Maier, Joachim Hornegger,
%       "A Unified Bayesian Approach to Multi-Frame Super-Resolution and 
%       Single-Image Upsampling in Multi-Sensor Imaging", BMVC 2015
%
%   ----------------------------------------------------------------------
%   Iteratively re-weighted optimization for robust super-resolution 
%   (IRW-SR)
%   ----------------------------------------------------------------------
%       X = SUPERRESOLVE(Y, MODEL, 'reweightedSR') reconstructs the high-
%       resolution image X from the low-resolution frames in Y using robust
%       iteratively re-weighted minimization.
%
%       X = SUPERRESOLVE(..., OPTS) performs iteratively re-weighted
%       minimization based on the optimization parameters in OPTS. 
%       see also getReweightedOptimizationParams
%
%       References:
%       Thomas Köhler, Xiaolin Huang, Frank Schebesch, André Aichert, 
%       Andreas Maier, Joachim Hornegger: Robust Multi-Frame Super-
%       Resolution Employing Iteratively Re-Weighted Minimization, 
%       IEEE Transactions on Computational Imaging, 2016

    if nargin < 3
        method = 'map';
    end
    
    switch (method)
            
        case 'map'
            % MAP super-resolution
            [SR, report] = mapsr(LRImages, model, varargin{:});
			varargout{1} = report;
             
		case 'mapqsa'
            % MAP super-resolution with quality self-assessment (MAP-QSA)
            [SR, weightScore] = mapsrqsa(LRImages, model, varargin{:});
            varargout{1} = weightScore;
			
        case 'irls'
            % Iteratively re-weighted least squares (IRLS) approach
            SR = irlssr(LRImages, model, varargin{:});
            
        case 'multisens'
            % Multi-sensor super-resolution
            [SR, modelTransformed] = multisenssr(LRImages, model, varargin{:});
            varargout{1} = modelTransformed;
        
        case 'guidedsr'
            % Guided super-resolution based on iteratively re-weighted
            % least squares (IRLS) minimization
            [SR, SR_guide] = guidedsr(LRImages, model, varargin{:});
            varargout{1} = SR_guide;
			
		case 'llr'
            % Multi-channel super-resolution using the locally linear
            % regression (LLR) model.
            if nargout > 1
                [SR, varargout{1}] = llrMultichannel(LRImages, model, varargin{:});
            else
                SR = llrMultichannel(LRImages, model, varargin{:});
            end
			     
        case 'bep'
            % Super-resolution using the bilateral edge preserving
            % regularization.
            [SR, report] = bepsr(LRImages, model, varargin{:});
            varargout{1} = report;
				
        case 'reweightedSR'
            % Robust multi-frame super-resolution using iteratively
            % re-weighted minimization.
            [SR, model, report] = reweightedOptimizationSR(LRImages, model, varargin{:});
            varargout{1} = model;
            varargout{2} = report;
        
        case 'calmsr'
            [SR, report] = calmsr(LRImages, model, varargin{:});
            varargout{1} = report;
            
        otherwise
            error('Undefined super-resolution method %s', method);
            
    end
