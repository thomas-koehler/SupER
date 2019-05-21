% Feature sign search
% code by Wang Jinjun @ NEC Research Lab America
% reference
% Efficient sparse coding algorithms
%   Honglak Lee Alexis Battle Rajat Raina Andrew Y. Ng
%       Computer Science Department
%       Stanford University
%       Stanford, CA 94305

function [x]=feature_sign(B,y,lambda,init_x)

nbases=size(B,2);

OptTol = 1e-5;

if nargin < 4,
    x=zeros(nbases, 1);
else
    x = init_x;
end;

theta=sign(x);          %sign flag
a=(x~=0);               %active set

optc=0;                

By=B'*y;
B_h=B(:,a);
x_h=x(a);
Bx_h=B_h*x_h;
all_d=2*(B'*Bx_h-By);
[ma mi]=max(abs(all_d).*(~a));

while optc==0,
    
    optc=1;

    if all_d(mi)>lambda+1e-10,
        theta(mi)=-1;
        a(mi)=1;
        b=B(:,mi);
        x(mi)=(lambda-all_d(mi))/(b'*b*2);            
    elseif all_d(mi)<-lambda-1e-10,
        theta(mi)=1;
        a(mi)=1;
        b=B(:,mi);
        x(mi)=(-lambda-all_d(mi))/(b'*b*2);            
    else
        if sum(a)==0,      
            lambda=ma-2*1e-10;
            optc=0;
            b=B(:,mi);
            x(mi)=By(mi)/(b'*b);
            break;
        end
    end 

    opts=0;
    B_h=B(:,a);
    x_h=x(a);
    theta_h=theta(a);
 
    while opts==0,
        opts=1;

        if size(B_h,2)<=length(y),
            BB=B_h'*B_h;
            x_new=BB\(B_h'*y-lambda*theta_h/2);
            o_new=L1_cost(y,B_h,x_new,lambda);
            
            %cost based on changing sign
            s=find(sign(x_new)~=theta_h);
            x_min=x_new;
            o_min=o_new;
            for j=1:length(s),
                zd=s(j);
                x_s=x_h-x_h(zd)*(x_new-x_h)/(x_new(zd)-x_h(zd));
                x_s(zd)=0;  %make sure it's zero
                o_s=L1_cost(y,B_h,x_s,lambda);
                if o_s<o_min,
                    x_min=x_s;
                    o_min=o_s;
                end
            end
        else
            d=x_h-B_h'*((B_h*B_h')\(B_h*x_h));
            q=x_h./(d+eps);
            x_min=x_h;
            o_min=L1_cost(y,B_h,x_h,lambda);
            for j=1:length(q),
                zd=q(j);
                x_s=x_h-zd*d;
                x_s(j)=0;       %make sure it's zero
                o_s=L1_cost(y,B_h,x_s,lambda);
                if o_s<o_min,
                   x_min=x_s;
                   o_min=o_s;
                end
            end
        end
        
        x(a)=x_min;

        a=(x~=0);
        theta=sign(x);

        B_h=B(:,a);
        x_h=x(a);
        theta_h=theta(a);
        Bx_h=B_h*x_h;

        active_d=2*(B_h'*(Bx_h-y))+lambda*theta_h;
      
        if ~isempty(find(abs(active_d)>OptTol)),
            opts=0;
        end
    end
       
    all_d=2*(B'*Bx_h-By);
        
    [ma mi]=max(abs(all_d).*(~a));
    if ma>lambda+OptTol,
        optc=0;
    end
end

return;

function cost=L1_cost(y,B,x,lambda)
    tmp = y-B*x;
    cost = tmp'*tmp+lambda*norm(x,1);
return


