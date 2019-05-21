function out = shift_img(in,s1,s2)

n = length(in);
[M,N,k] = size(in{1});

out = [];

for i = 1:n
    out{i} = zeros(M,N,k);
    out{i}(:,:,1) = circshift(in{i}(:,:,1), [s1,s2]);
    out{i}(:,:,2) = circshift(in{i}(:,:,2), [s1,s2]);
    out{i}(:,:,3) = circshift(in{i}(:,:,3), [s1,s2]);
end