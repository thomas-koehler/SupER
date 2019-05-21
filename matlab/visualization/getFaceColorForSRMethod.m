function [facecolor, linestyle, marker] = getFaceColorForSRMethod(srMethodName)
    
    srMethods = {'nn', 'bicubic', 'ebsr', 'scsr', 'nbsrf', 'aplus', 'srcnn', 'drcn', 'vdsr', 'sesr', 'nuisr', 'wnuisr', 'hysr', 'dbrsr', 'l1btv', 'bepsr', 'irwsr', 'bvsr', 'srb', 'vsrnet'};
    
    % Get face color for the SR method.
    colorMap = jet(30);
    facecolor = [colorMap(1:10,:); colorMap(21:30,:)];    
    facecolor = facecolor( strcmp(srMethodName, srMethods), :);
    
    if nargout > 1
        % Get line style for the SR method.
        linestyle = cellstr(char('-', ':', '-.', '--', '-', ':', '-.', '--', '-', ':', '-.', '--', '-', ':', '-.', '--', '-', ':', '-.', '--'));
        linestyle = linestyle{ strcmp(srMethodName, srMethods) };
    end
    
    if nargout > 2
        % Get marker for the SR method.
        marker = ['o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>', 'o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>'];
        marker = marker(strcmp(srMethodName, srMethods));
    end
    
    