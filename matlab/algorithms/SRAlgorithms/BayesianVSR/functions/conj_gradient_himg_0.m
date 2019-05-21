function x = conj_gradient_himg_0(Ax,x0,b,W0,Ws,th,h_2d,opt,param)

%A = th(j)K'S'W0SK + eta*(Dx'WsDx+Dy'WsDy)
%b = th(j)K'S'W0J0
%I = A \ b;

DRAW = SHOW_IMAGE;

maxit = 200;
eps = 0.01;

% init
r = Ax(:) - b(:);
p = -r;
k = 0;
x = x0(:);
rsize = length(r);

while k < maxit
    p_m = reshape(p,opt.M,opt.N);
    Ap_m = compute_Ax(p_m,W0,Ws,th,h_2d,opt);
    Ap = Ap_m(:);
    alpha = (r'*r) / (p'*Ap) ;
    x = x + alpha*p;
    r_new = r + alpha*Ap;
    beta = (r_new'*r_new) / (r'*r);
    p_new = -r_new + beta*p;
    
    if DRAW
        diff_r_img = norm(r_new)/rsize
    else
        diff_r_img = norm(r_new)/rsize;
    end
    
    if diff_r_img < eps
        diff_r_img
        k
        break;
    end
    
    k = k + 1;
    r = r_new;
    p = p_new;
    
    if DRAW
        x1 = reshape(x,opt.M,opt.N);
        figure(99), imshow(x1); drawnow;    
    end
end

x = reshape(x,opt.M,opt.N);
