function y = cconv2d(h, x)

[m,n] = size(x);
[mh,nh] = size(h);

if m < mh || n <nh
    error('size of kernel must be bigger than image');
end

%hz = padarray(h, [m-mh, n-nh], 'post');
%hz = circshift(hz, [-(mh-1)/2,-(nh-1)/2]);

fft_h = psf2otf(h,size(x));
fft_x = fft2(x);

fft_y = fft_h .* fft_x;

y = ifft2(fft_y);
