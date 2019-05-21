function g = btvPrior_grad(x, imsize, P, alpha)

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
            Xshift = Xpad((1+P-l):(end-P-l), (1+P-m):(end-P-m));

            % Subtract from HR image and compute sign
            Xsign = sign(X - Xshift);
    
            % Shift Xsign back by -l and -m
            Xsignpad = padarray(Xsign, [P P], 0);
            Xshift = Xsignpad((1+P+l):(end-P+l), (1+P+m):(end-P+m));
            
            % Compute gradient
            G = G + alpha.^(abs(l)+abs(m)).*(Xsign-Xshift);
        end
    end
    
    % Linearize gradient to a vector.
    g = imageToVector(G);