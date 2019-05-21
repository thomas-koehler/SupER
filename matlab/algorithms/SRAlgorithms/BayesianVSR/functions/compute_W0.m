function W0 = compute_W0(I,J0,h_2d,upscale)

KI = cconv2d(h_2d,I);
SKI = down_sample(KI,upscale);
W0 = weight_matrix(SKI - J0);
