function [h_1d, h_2d] = create_blur_kernel(Kx,opt)

FIX_HSIZE = 1; % hsize = 11
HSIZE = 15;
eps = 0.01;

if FIX_HSIZE
    V = [Kx(1:floor(HSIZE/2)+1); Kx(opt.N-floor(HSIZE/2)+1:opt.N)];
    V = circshift(V, floor(HSIZE/2));
else
    for i = 1:length(Kx)
        if i>2 && Kx(i) < eps
            halflen = i-2;
            break
        end
    end

    len = 2*halflen + 1;
    V = zeros(1, len);
    for i = 1:halflen
        V(i) = Kx(opt.N - halflen + i);
    end
    for i = halflen+1:len
        V(i) = Kx(i-halflen);
    end
end

V = V / sum(V);

h_1d = V';
h_2d = h_1d'*h_1d;