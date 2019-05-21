function opts = SRPrior(varargin)
%SRPRIOR Super-resolution image prior.
%   SRPRIOR returns a parameter structure to represent an image prior for
%   resolution using default settings.
%
%   The parameter structure consist of the following parameters:
%       - function:     Function handle to provide a regularization term 
%                       for the prior.
%       - gradient:     Function handle to gradient of the regularizer.
%       - weight:       Regularization/prior weight.
%       - parameters:   Additional parameters passed to the regularizer and
%                       the gradient function.

opts = struct('function',   @huberPrior, ...        % Function handle to prior (default: Huber)
              'gradient',   @huberPrior_grad, ...   % Function handle to gradient
              'weight',     0, ...                  % Regularization weight
              'parameters', [], ...                 % Additional parameters passed to prior function/gradient
              'weightEvaluationFunction', []);                    
          
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