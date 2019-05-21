% Fit Bradley-Terry (BT) model from a winning matrix using expectation 
% maximization according to Wei-Sheng La et al. "A Comparative Study for 
% Single Image Blind Deblurring", CVPR 2016
function s = fitBTModel(C)
    
    % Maximum number of EM iterations and desired termination tolerance.
    numIter = 5000;
    tol = 1e-8;
    
    % Initialize BT scores.
    N = C + C';
    n = size(N, 1);             % Number of methods
    s = ones(size(N, 1), 1);    % BT scores for different methods
    
    % Perform EM iterations.
    delta = realmax;
    iter = 0;
    while norm(delta) > tol && iter < numIter

        % EM update for BT scores.
        L = repmat(exp(s)', n, 1) + repmat(exp(s), 1, n);
        s_new = log( sum(C, 2) ./ sum(N ./ L, 2) );
        
        % Proceed with next iteration.
        delta = s_new - s;
        s = s_new;
        iter = iter + 1;
        
    end