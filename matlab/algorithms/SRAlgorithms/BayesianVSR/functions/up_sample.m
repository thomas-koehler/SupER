function y = up_sample(x, scale)

[m,n] = size(x);

y = zeros(m*scale,n*scale);
for i = 1:m
    for j = 1:n
        y((i-1)*scale+1,(j-1)*scale+1) = x(i,j);
    end
end
