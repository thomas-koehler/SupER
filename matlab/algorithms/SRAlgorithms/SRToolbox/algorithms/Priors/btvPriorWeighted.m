function [f, z] = btvPriorWeighted(x, imsize, P, alpha, weights)

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
    f = 0;
    z = {};
    k = 1;
    for l=-P:P
        for m=-P:P
            
            if l ~= 0 || m ~= 0
                if nargin < 5 || isempty(weights)
                    w = 1;
                else
                    w = weights( (numel(X)*(k-1) + 1):(numel(X)*k) );
                    k = k + 1;
                end
            
                % Shift by l and m pixels.
                Xshift = Xpad((1+P-l):(end-P-l), (1+P-m):(end-P-m));    
            
                z{l+P+1, m+P+1} = imageToVector( alpha^(abs(l) + abs(m)) * (Xshift - X) );
                f = f + alpha.^(abs(l)+abs(m)) .* sum( w(:) .* lossFun(Xshift(:) - X(:)) );     
            end

        end
    end
    
function h = lossFun(x)
    
    mu = 1e-4;
    h = sqrt(x.^2 + mu);
    
    
    