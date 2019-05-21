function qualityMeasure = callQualityMeasure(sr, gt, qualityMeasureName)
    
    % Assemble name of the quality measure wrapper function.
    funName = sprintf('imageQuality_%s', qualityMeasureName);
    
    % Call the desired quality measure.
    qualityMeasure = feval(funName, sr, gt);