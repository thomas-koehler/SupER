function srImage = callSRMethod(slidingWindow, magFactor, srMethod)
    
    % Assemble name of the SR wrapper function.
    funName = sprintf('superresolve_%s', srMethod.name);
    
    % Call the desired SR method.
    srImage = feval(funName, slidingWindow, magFactor);