function x = conj_gradient_kernel(Ax,x0,b,Wk,Ws,th,I,opt,param)

%A = th(j)My'I1'S'W0SI1My + xi*(Dx_k'WsDx_k+Dy_k'WsDy_k);
%b = th(j)My'I1'S'W0J0(:);
%Kx = A \ b;

MASK = 0;
DRAW = 0;%param.SHOW_IMAGE;

maxit = 100;
eps = 0.01;

if MASK
    tmp = ones(opt.M,opt.N);
    hwnd = floor(opt.hsize/2);
    for i = 1:opt.M
        for j = 1:opt.N
            if  i<opt.M/2-hwnd || i>opt.M/2+hwnd || j<opt.N/2-hwnd || j>opt.N/2+hwnd
                tmp(i,j) = 0;
            end
        end
    end
    mask = tmp(:);
end

% init
r = Ax(:) - b(:);
p = -r;
k = 0;
x = x0(:);
rsize = length(r);

while k < maxit
    p_m = reshape(p,opt.M,opt.N);
    Ap_m = compute_Ax_k(p_m,Wk,Ws,th,I,opt);
    Ap = Ap_m(:);
    alpha = (r'*r) / (p'*Ap) ;
    x = x + alpha*p;
    r_new = r + alpha*Ap;
    beta = (r_new'*r_new) / (r'*r);
    p_new = -r_new + beta*p;

    if DRAW
        diff_r_kernel = norm(r_new)/rsize
    else
        diff_r_kernel = norm(r_new)/rsize;
    end
    
    if diff_r_kernel < eps 
        break;
    end
    
    k = k + 1;
    r = r_new;
    p = p_new;
    
    if MASK
        x = mask .* x;
        x = x / sum(x);
    end

    if DRAW
        x1 = reshape(x,opt.M,opt.N);
        figure(99), imagesc(x1); drawnow;
    end
end

x = reshape(x,opt.M,opt.N);
