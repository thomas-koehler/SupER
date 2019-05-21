% Calculate Kendall coefficient of agreement from a winning matrix
% according to Wei-Sheng La et al. "A Comparative Study for Single Image 
% Blind Deblurring", CVPR 2016
function u = coefficientOfAgreement(C)
    
    % Number of methods described by the winning matrix.
    numMethods = sum(sum(C + C', 2) > 0);
    % Number of observers for the winning matrix.
    numUsers = round(sum(C(:)) / nchoosek(numMethods, 2) );

    C = C(:);
    C = C(C > 1); 
    w = 0;
    for i = 1:length(C)
        w = w + nchoosek(C(i), 2);
    end
    
    u = (2 * w) / ( nchoosek(numMethods, 2) * nchoosek(numUsers, 2) ) - 1;