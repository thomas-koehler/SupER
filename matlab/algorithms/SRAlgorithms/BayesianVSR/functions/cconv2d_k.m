function y = cconv2d_k(h, x)

[m,n] = size(x);
[mh,nh] = size(h);

if m < mh || n <nh
    error('size of kernel must be bigger than image');
end


%fft_h = conj(psf2otf(h));
%fft_x = fft2(x);
%fft_y = fft_h .* fft_x;

fft_y = conj(psf2otf(x)).*fft2(h);

y = ifft2(fft_y);

