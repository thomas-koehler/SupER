function W = weight_matrix(x, eps)

if nargin < 2
    eps = 1e-10;
end

[M,N] = size(x);

W = zeros(M,N);

for i = 1:M
    for j = 1:N
        W(i,j) = 1 / sqrt(x(i,j)*x(i,j) + eps*eps);
    end
end
