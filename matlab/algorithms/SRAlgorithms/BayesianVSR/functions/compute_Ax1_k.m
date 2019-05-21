function AK1 = compute_Ax1_k(K,I,Wk,th,opt)

%A = th(j)*My'*I1'*S'*Wk*S*I1*My * Kx
%A = th(j)*I1'*S'*Wk*S*I1 * K

AK = cconv2d(K,I);
SAK = down_sample(AK,opt.res);
WkSAK = Wk .* SAK;
StWkSAK = up_sample(WkSAK,opt.res);
%AtStWkSAK = cconv2d(StWkSAK,I); 
AtStWkSAK = cconv2dt(I,StWkSAK); 

AK1 = th * AtStWkSAK;
