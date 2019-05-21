function AI2 = compute_Ax2(I,Ws)

% AI2 = opt(l).eta*(Dx'*Ws*Dx+Dy'*Ws*Dy) * I;

if 0
    dx = [0 0 0; -1 1 0; 0 0 0]; % for x-derivative filter
    dy = [0 -1 0; 0 1 0; 0 0 0]; % for y-derivative filter
else
    dx = [0 0 0; -1 0 1; 0 0 0]; % for x-derivative filter
    dy = [0 -1 0; 0 0 0; 0 1 0]; % for y-derivative filter
end

DxI = cconv2d(dx,I);
WsDxI = Ws .* DxI;
DxtWsDxI = cconv2dt(dx,WsDxI);
%DxtWsDxI = cconv2d(dx_t,WsDxI);

DyI = cconv2d(dy,I);
WsDyI = Ws .* DyI;
DytWsDyI = cconv2dt(dy,WsDyI);
%DytWsDyI = cconv2d(dy_t,WsDyI);

AI2 = DxtWsDxI + DytWsDyI;