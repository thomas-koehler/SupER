function x = conj_gradient_method(A, b)

%Parameters
n = 20;

%Initialization
clc
format short e
tol = 1e-2;

r = A*x-b;
p = -r;
k = 0;
abs_r = sqrt(r'*r);

while abs_r > tol
    
    alpha = (r'*r)/(p'*A*p);
    
    x = x+alpha*p;
    r_old = r;
    r = r + alpha*A*p;
    beta = (r'*r)/(r_old'*r_old);
    p = -r+beta*p;
    k=k+1;
    
    abs_r = sqrt(r'*r);
%    disp([k abs_r alpha]);
end






