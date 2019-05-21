function AI3 = compute_Ax3(FI,Wi,th,h_2d,upscale,ut,vt)

KFI = cconv2d(h_2d,FI);
SKFI = down_sample(KFI,upscale);
WSKFI = Wi .* SKFI;
StWSKFI = up_sample(WSKFI, upscale);
KtStWSKFI = cconv2dt(h_2d,StWSKFI);
FtKtStWSKFI = warped_img(KtStWSKFI,ut,vt);

AI3 = th * FtKtStWSKFI;