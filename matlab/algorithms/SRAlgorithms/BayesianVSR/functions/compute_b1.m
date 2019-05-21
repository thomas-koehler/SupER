function b = compute_b1(J0,W0,th,h_2d,opt)

W0J = W0 .* J0;
StW0J = up_sample(W0J, opt.res);
KtStW0J = cconv2dt(h_2d,StW0J);

b = th*KtStW0J;