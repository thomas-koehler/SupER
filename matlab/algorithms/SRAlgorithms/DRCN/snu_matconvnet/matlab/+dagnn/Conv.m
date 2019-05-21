classdef Conv < dagnn.Filter
  properties
    size = [0 0 0 0]
    hasBias = true
    opts = {'cuDNN'}
    init = [1 0]
    initIdentity = false
    alpha = 1 % alpha for the importance of center to center propagation. rest propagation divides among (1-alpha)
  end
  
  methods
    function outputs = forward(obj, inputs, params)
      if ~obj.hasBias, params{2} = [] ; end
      outputs{1} = vl_nnconv(...
        inputs{1}, params{1}, params{2}, ...
        'pad', obj.pad, ...
        'stride', obj.stride, ...
        obj.opts{:}) ;
    end
    
    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      if ~obj.hasBias, params{2} = [] ; end
      [derInputs{1}, derParams{1}, derParams{2}] = vl_nnconv(...
        inputs{1}, params{1}, params{2}, derOutputs{1}, ...
        'pad', obj.pad, ...
        'stride', obj.stride, ...
        obj.opts{:}) ;
    end
    
    function kernelSize = getKernelSize(obj)
      kernelSize = obj.size(1:2) ;
    end
    
    function outputSizes = getOutputSizes(obj, inputSizes)
      outputSizes = getOutputSizes@dagnn.Filter(obj, inputSizes) ;
      outputSizes{1}(3) = obj.size(4) ;
    end
    
    function params = initParams(obj)
      if ~obj.initIdentity % Kaiming He's Initialization Method
        sc = sqrt(2 / prod(obj.size(1:3))) ;
        params{1} = obj.init(1) * randn(obj.size,'single') * sc ;
        if obj.hasBias
          params{2} = obj.init(2) + zeros(obj.size(4),1,'single') * sc ;
        end
      else
        params{1} = zeros(obj.size, 'single');
        if mod(obj.size(1), 2)
          for i=1:obj.size(1)
            for j=1:obj.size(2)
              params{1}(i,j,:,:) = (1 - obj.alpha) / (obj.size(1)*obj.size(2)-1) * eye([obj.size(3) obj.size(4)], 'single');
            end
          end
          params{1}(obj.size(1)/2+0.5, obj.size(2)/2+0.5,:,:) = obj.alpha * eye([obj.size(3) obj.size(4)], 'single');
        else
          params{1}(obj.size(1)/2:obj.size(1)/2+1, obj.size(2)/2:obj.size(2)/2+1,:,:) = eye([obj.size(3) obj.size(4)], 'single');
        end
        if obj.hasBias
          params{2} = zeros(obj.size(4),1,'single');
        end
      end
    end
    
    function obj = Conv(varargin)
      obj.load(varargin) ;
    end
  end
end
