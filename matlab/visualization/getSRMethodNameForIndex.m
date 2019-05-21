function methodName = getSRMethodNameForIndex(index)
    
    if length(index) == 1
        if index == 0
            methodName = 'groundTruth';
        else
            methodNameArray = SRMethods;
            methodName = methodNameArray(index).name;
        end
    else
        for k = 1:length(index)
            methodName{k} = getSRMethodNameForIndex(index(k));
        end
    end