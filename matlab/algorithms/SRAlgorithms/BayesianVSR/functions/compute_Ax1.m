function AI1 = compute_Ax1(I,W0,th,h_2d,opt)

% AI1 = th(j)*K'*S'*W0*S*K * I

KI = cconv2d(h_2d,I);
SKI = down_sample(KI,opt.res);
W0SKI = W0 .* SKI;
StW0SKI = up_sample(W0SKI,opt.res);
KtStW0SKI = cconv2dt(h_2d,StW0SKI);

AI1 = th * KtStW0SKI;
