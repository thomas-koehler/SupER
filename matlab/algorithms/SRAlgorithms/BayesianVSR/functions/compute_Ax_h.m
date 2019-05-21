function Ax = compute_Ax_h(x,W0,Ws,th,h_2d,opt,j,n_back,n_for,FI,Wi,ut,vt,param)

Ax3 = zeros(opt.M,opt.N);
for i = -n_back:n_for
    if i == 0
       Ax3_tmp = zeros(opt.M,opt.N);
    else
       Ax3_tmp = compute_Ax3(FI{j+i},Wi{j+i},th(j+i),h_2d,opt.res,ut{j+i},vt{j+i});
    end
    Ax3 = Ax3 + Ax3_tmp;
end

Ax1 = compute_Ax1(x,W0,th(j),h_2d,opt);
Ax2 = compute_Ax2(x,Ws);

Ax = Ax1 + opt.eta*Ax2 + Ax3;
