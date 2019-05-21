function Kx = create_Kx1(h_1d, opt)

size_h = length(h_1d);
if size_h > opt.M || size_h > opt.N
    error('blur kernel must be smaller than image');
end

Kx_tmp = [h_1d'; zeros(opt.N-size_h,1)];
Kx = circshift(Kx_tmp, [-floor(size_h/2), 0]);
%Ky = padarray(h_tmp, [0, opt.N-1], 'post');
%Ky = Ky(:);

end