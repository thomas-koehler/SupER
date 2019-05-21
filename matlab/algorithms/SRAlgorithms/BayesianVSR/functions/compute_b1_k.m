function b = compute_b1_k(J0,Wk,th,I,opt)

WkJ = Wk .* J0;
StWkJ = up_sample(WkJ, opt.res);
AtStWkJ = cconv2dt(I,StWkJ);

b = th*AtStWkJ;