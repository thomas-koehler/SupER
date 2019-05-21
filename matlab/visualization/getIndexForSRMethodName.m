function index = getIndexForSRMethodName(methodName)

    srMethods = SRMethods;
    
    if strcmp(methodName, 'groundTruth')
        index = 0;
    else
        index = find(strcmpi({srMethods(:).name}, methodName));
    end
 