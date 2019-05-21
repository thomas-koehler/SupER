function g = btvPriorWeighted_grad(x, imsize, P, alpha, weights)

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
    k = 1;
    for l=-P:P
        for m=-P:P
            
            if l ~= 0 || m ~= 0
                % Shift by l and m pixels
                Xshift = Xpad((1+P-l):(end-P-l), (1+P-m):(end-P-m));

                % Subtract from HR image and compute sign
                Xsign = lossFun_grad(X - Xshift);
            
                % Shift Xsign back by -l and -m
                Xsignpad = padarray(Xsign, [P P], 0);
                Xshift = Xsignpad((1+P+l):(end-P+l), (1+P+m):(end-P+m));
                
                if nargin < 5 || isempty(weights)
                    w = ones(size(Xsign));
                else
                    w = weights( (numel(X)*(k-1) + 1):(numel(X)*k) );
                    k = k + 1;
                end
                
                % Compute gradient
                G = G + alpha.^(abs(l)+abs(m)) .* vectorToImage(w, imsize) .* (Xsign-Xshift);
            end
            
        end
    end
    
    % Linearize gradient to a vector.
    g = imageToVector(G);
    
 function hg = lossFun_grad(x)
     
     mu = 1e-4;
     hg = x ./ sqrt(x.^2 + mu);