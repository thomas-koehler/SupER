% Calculate weighted Kendall distance tau(delta, f) (normalized or 
% unnormalized version) according to Y. Liu et al., “A No-Reference Metric 
% for Evaluating the Quality of Motion Deblurring,” ACM Transactions on 
% Graphics, 2013
function tau = weightedKendallDistance(delta, f, norm)
    
    if nargin < 3
        norm = false;
    end
    
    if norm
        % Compute the normalized version of the weighted Kendall distance.
        tau = weightedKendallDistance(delta, f) / weightedKendallDistance(delta, -delta);
    else
        % Compute the unormalized version.
        tau = 0;
        for i = 1:length(delta)
            for j = 1:length(delta)
                if ((delta(i) > delta(j)) && (f(i) <= f(j))) || ((delta(i) < delta(j)) && f(i) >= f(j))
                    % Check if the order of the i-th and the j-th elements
                    % agree in both sets.
                    tau = tau + abs( (max(delta(i), delta(j)) - min(delta)) * (delta(i) - delta(j)) );
                end
            end
        end
    end