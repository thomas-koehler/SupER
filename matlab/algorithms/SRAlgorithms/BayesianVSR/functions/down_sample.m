function y = down_sample(x,scale)

[M,N] = size(x);

if mod(M,scale) ~= 0 || mod(N,scale) ~= 0
    error('size of x must be divided by N');
end

y = zeros(M/scale,N/scale);
for i = 1:M/scale
    for j = 1:N/scale
        y(i,j) = x((i-1)*scale+1, (j-1)*scale+1);
    end
end
