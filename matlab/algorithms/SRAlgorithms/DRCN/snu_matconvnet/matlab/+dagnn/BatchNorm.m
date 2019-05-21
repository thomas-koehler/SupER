classdef BatchNorm < dagnn.ElementWise
  properties
    ndim = 1;
    mu = [];
    sigma = [];
    nAccum = 0;
    nbatch = 0;
    compVar = 0;
  end
  
  methods
    function outputs = forward(obj, inputs, params)
      if strcmp(obj.net.mode, 'test')
        outputs{1} = vl_nnbnorm(inputs{1}, params{1}, params{2}, 'Moments', [obj.mu,obj.sigma]) ;
        obj.nAccum = 0;
        return ;
      end
      outputs{1} = vl_nnbnorm(inputs{1}, params{1}, params{2}) ;
    end

    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      derInputs{1} = vl_nnrelu(inputs{1}, derOutputs{1}) ;
      [derInputs{1}, derParams{1}, derParams{2}, moments] = ...
          vl_nnbnorm(inputs{1}, params{1}, params{2}, derOutputs{1}) ;
      obj.mu = obj.nAccum * obj.mu + moments(:, 1);
      obj.sigma = obj.nAccum * obj.sigma + obj.compVar * moments(:, 2);
      obj.nAccum = obj.nAccum + 1;
      obj.mu = obj.mu / obj.nAccum;
      obj.sigma = obj.sigma / obj.nAccum;
    end
    
    function params = initParams(obj)
      params{1} = ones(obj.ndim, 1, 'single');
      params{2} = zeros(obj.ndim, 1, 'single');
      obj.mu = zeros(obj.ndim, 1, 'single');
      obj.sigma = zeros(obj.ndim, 1, 'single');
      obj.nAccum = 0;
      if obj.nbatch < 2
          obj.compVar = 1;
      else
          obj.compVar = sqrt(obj.nbatch / (obj.nbatch - 1));
      end
    end
    
    function obj = BatchNorm(varargin)
      obj.load(varargin) ;
    end
  end
end
