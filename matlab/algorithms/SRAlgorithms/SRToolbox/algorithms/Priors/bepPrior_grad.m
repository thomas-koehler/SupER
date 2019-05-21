function g = bepPrior_grad(x, imsize, P, alpha, bepThreshold)

    if nargin < 3
        P = 1;
    end
    if nargin < 4
        alpha = 0.7;
    end
    
    % Reshape SR vector to image for further processing.
    X = vectorToImage(x, imsize);
        
    % Pad image at the border to perform shift operations.
    Xpad = padarray(X, [P P], 'symmetric');

    % Consider shifts in the interval [-P, +P].
    G = zeros(size(X));
    for l=-P:P
        for m=-P:P
            % Shift by l and m pixels
            eshift = Xpad((1+P-l):(end-P-l), (1+P-m):(end-P-m));
            
            % Calculate difference image.
            e = X - eshift;
            
            % Calculate adaptive weights.
            w = bepThreshold ./ sqrt(bepThreshold^2 + e.^2);
                
            % Shift Xsign back by -l and -m
            epad = padarray(e, [P P], 0);
            eshift = epad((1+P+l):(end-P+l), (1+P+m):(end-P+m));
            
            % Compute gradient
            G = G + alpha.^(abs(l)+abs(m)) .* w .* (e - eshift);
        end
    end
    
    % Linearize gradient to a vector.
    g = imageToVector(G);