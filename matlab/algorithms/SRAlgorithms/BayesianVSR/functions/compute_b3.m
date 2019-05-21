function b3 = compute_b3(J,Wi,th,h_2d,upscale,ut,vt)

WJ = Wi .* J;
StWJ = up_sample(WJ,upscale);
KtStWJ = cconv2dt(h_2d,StWJ);
FtKtStWJ = warped_img(KtStWJ,ut,vt);

b3 = th .* FtKtStWJ;
