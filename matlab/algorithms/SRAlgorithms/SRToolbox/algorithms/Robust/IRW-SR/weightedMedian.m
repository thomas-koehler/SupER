function med = weightedMedian(Z, weights)

    % Weight normalization.
    weights = weights / sum(weights(:));
    % Reshape to vectors.
    if ~isvector(weights)
        weights = weights(:);
    end
    if ~isvector(Z)
        Z = Z(:);
    end

    % Sort the data vector according to the given weight vector.
    Z_and_weights_sorted = sortrows([Z weights], 1);
    ZSorted = Z_and_weights_sorted(:,1);
    weightsSorted = Z_and_weights_sorted(:,2);

    % Compute the cumulative sum of the weights.
    weightsCumSum = cumsum(weightsSorted);
    % Select the weighted median according to the cumulative sum of the
    % weights.
    med = ZSorted(1);
    for k = 1:length(weightsCumSum)
        if weightsCumSum(k) >= 0.5
            % We found the weighted median as the sum exceeds 0.5.
            med = ZSorted(k);
            return;
        end
    end