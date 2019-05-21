function Wk = compute_Wk(K,I,J0,upscale)

AK = cconv2d(K,I);
SAK = down_sample(AK,upscale);

Wk = weight_matrix(SAK - J0);
