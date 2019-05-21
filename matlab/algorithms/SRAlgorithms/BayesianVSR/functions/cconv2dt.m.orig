function y = cconv2dt(h, x)

[m,n] = size(x);
[mh,nh] = size(h);

if m < mh || n < nh
    error('size of kernel must be bigger than image');
end

%fft_y = conj(psf2otf(h,size(x))).*fft2(x);


fft_h = conj(psf2otf(h,size(x)));
fft_x = fft2(x);

fft_y = fft_h .* fft_x;

y = ifft2(fft_y);

