function Ax = compute_Ax(I,W0,Ws,th,h_2d,opt)

AI1 = compute_Ax1(I,W0,th,h_2d,opt);
AI2 = compute_Ax2(I,Ws);

Ax = AI1 + opt.eta*AI2;