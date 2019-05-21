function [h_1d,h_2d] = create_h(sigma_h, size_h, opt, mode)

if sigma_h > opt.M || sigma_h > opt.N
    error('blur kernel must be smaller than image');
end

if mode == 1
    x = linspace(-size_h/2, size_h/2, size_h);
    h_1d = exp(-x.^2 / (2 * sigma_h^2)); % 1D Guassian filter kernel
    h_1d = h_1d / sum(h_1d); % normalize
    h_2d = kron(h_1d',h_1d);
elseif mode == 2
    h_2d = ones(size_h,size_h) / (size_h*size_h);
end
