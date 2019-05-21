function x = conj_gradient_himg(Ax,x0,b,W0,Ws,th,h_2d,opt,j,n_back,n_for,FI,Wi,ut,vt,param)

%A = th(j)K'S'W0SK + eta*(Dx'WsDxDy'WsDy) + sum(th(j)F'K'S'W0SKF)
%b = th(j)K'S'W0J0;
%I = A \ b;

DRAW = param.SHOW_IMAGE;

maxit = 5;
eps = 0.1;

% init
r = Ax(:) - b(:);
p = -r;
k = 0;
x = x0(:); %zeros(size(p));
rsize = length(r);

while k < maxit
    p_m = reshape(p,opt.M,opt.N);
    Ap_m = compute_Ax_h(p_m,W0,Ws,th,h_2d,opt,j,n_back,n_for,FI,Wi,ut,vt,param);
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
