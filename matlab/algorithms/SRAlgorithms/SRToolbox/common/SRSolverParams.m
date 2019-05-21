function opts = SRSolverParams(varargin)
%SRSOLVERPARAMS Parameters for numerical optizimation.
%   SRSOLVERPARAMS returns a parameter structure used for numerical
%   optimization and computations in different super-resolution algorithms.
%
%   The parameter structure consist of the following parameters:
%       - maxFunEvals:  Maximum number of objective function evaluations.
%       - maxIter:      Maximum number of iterations for non-linear
%                       optimization.
%       - maxIrlsIter:  Maximum number of iterations for iteratively
%                       re-weighted least squares algorithms.
%       - tolX:         Measure of the absolute precision required for the
%                       super-resolved pixel values (termination
%                       tolerance).
%       - tolF:         Measure of the absolute precision required for
%                       objective functions in non-linear optimization
%                       (termination tolerance).
%       - gradCheck:    Set to 1 to check the analytic derived gradients
%                       for debug purposes.
%       - verbose:      Level for debug messages. Set to -1 for no
%                       messages, to 0 for only warning messages and 1 for 
%                       error messages.
    
    % Set default value to parameter structure
    opts = struct('maxFunEvals',         50, ...    % Maximim number of function evals
                  'maxIter',             50, ...    % Maximum number of iterations
                  'maxIrlsIter',         15, ...    % Maximum number of iteration for iteratively re-weighted least squares
                  'tolX',                1e-3, ...  % Tolerance criterion for image pixels
                  'tolF',                1e-3, ...  % Tolerance criterion for objective function value
                  'verbose',             false, ... % Use debug outputs
                  'gradCheck',           false);    % Check objective function gradient
    
    % Update with user-defined parameters
    for k = 1:2:(nargin - 1)
        
        param = varargin{k};
        value = varargin{k+1};
        if isfield(opts, param)
            opts = setfield(opts, param, value);
        else
            error( sprintf('Invalid parameter %s', param) );
        end
       
    end