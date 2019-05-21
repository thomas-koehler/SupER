function Wi = compute_Wi(FI,J,h_2d,upscale)

ONES = 0;

if ONES == 1
    Wi = ones(size(J));
else
    KFI = cconv2d(h_2d,FI);
    SKFI = down_sample(KFI,upscale);

    Wi = weight_matrix1(SKFI - J);
end
  