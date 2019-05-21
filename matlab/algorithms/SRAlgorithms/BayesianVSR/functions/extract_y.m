function y = extract_y(ycbcr)

N = length(ycbcr);
y = [];

for i = 1:N
    y{i} = ycbcr{i}(:,:,1);
end
    