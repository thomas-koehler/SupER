function b = compute_b_h(J,W0,th,h_2d,opt,j,n_back,n_for,Wi,ut,vt,param)

b3 = zeros(opt.M,opt.N);

for i = -n_back:n_for
   if i == 0
       b3_tmp = zeros(opt.M,opt.N);
   else
       b3_tmp = compute_b3(J{j+i},Wi{j+i},th(j+i),h_2d,opt.res,ut{j+i},vt{j+i});
   end
   b3 = b3 + b3_tmp;
end

b1 = compute_b1(J{j},W0,th(j),h_2d,opt);

b = b1 + b3;
