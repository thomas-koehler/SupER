function Ws = compute_Ws(I)

if 0
    dx = [0 0 0; -1 1 0; 0 0 0]; % for x-derivative filter
    dy = [0 -1 0; 0 1 0; 0 0 0]; % for y-derivative filter
else
    dx = [0 0 0; -1 0 1; 0 0 0]; % for x-derivative filter
    dy = [0 -1 0; 0 0 0; 0 1 0]; % for y-derivative filter
end

DxI = cconv2d(dx,I);
DyI = cconv2d(dy,I);

Ws = weight_matrix(abs(DxI)+abs(DyI), 1e-4);

