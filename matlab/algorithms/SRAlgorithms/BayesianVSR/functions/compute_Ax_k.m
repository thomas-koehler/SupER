function Ax = compute_Ax_k(x,Wk,Ws,th,I,opt)

Ax1 = compute_Ax1_k(x,I,Wk,th,opt);
Ax2 = compute_Ax2(x,Ws);

Ax = Ax1 + opt.xi*Ax2;