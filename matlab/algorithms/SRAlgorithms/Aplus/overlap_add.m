% Image construction from overlapping patches
function [result] = overlap_add(patches, img_size, grid)

result = zeros(img_size);
weight = zeros(img_size);
 
for i = 1:size(grid, 3)
    patch = reshape(patches(:, i), size(grid, 1), size(grid, 2));
    result(grid(:, :, i)) = result(grid(:, :, i)) + patch;
    weight(grid(:, :, i)) = weight(grid(:, :, i)) + 1;
end

I = logical(weight);
result(I) = result(I) ./ weight(I);
