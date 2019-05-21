%
% Author: Marius Drulea
% http://www.cv.utcluj.ro/optical-flow.html

% References
% M. Drulea and S. Nedevschi, "Total variation regularization of 
% local-global optical flow," in Intelligent Transportation Systems (ITSC), 
% 2011 14th International IEEE Conference on, 2011, pp. 318-323.

% Copyright (C) 2011 Technical University of Cluj-Napoca

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [u, v, pu, pv] = solve_clg_tv_equation(u, v, u0, v0, pu, pv, ...
    I1, Ix, Iy, It, D, settings)
%%
lambda = settings.lambda;

theta = 0.5;
tau = 0.5;
% tau = 1.0/(4.0*theta + epsilon);

der_mask = [0 -1 1];
adjoint_der_mask = [-1 1 0];

if settings.use_bilateral == 1     
     r0 = It - u0.*Ix - v0.*Iy;
    % apply the bilateral filter to the data terms
    [W_Ix_2, W_Ixy, W_Iy_2, W_Ix_r0, W_Iy_r0] = ...
    applyBilateralFilterToDataTerms(I1, Ix.*Ix, Ix.*Iy, Iy.*Iy, Ix.*r0, Iy.*r0, ...
        settings.wSize, settings.sigma_d, settings.sigma_r);
else                
    gauss = fspecial('gaussian', [settings.wSize settings.wSize], settings.wSize/6);

    W_Ix_2 = imfilter(Ix.^2, gauss, 'replicate');
    W_Ixy = imfilter(Ix.*Iy, gauss, 'replicate');
    W_Iy_2 = imfilter(Iy.^2, gauss, 'replicate');

    r0 = It - u0.*Ix - v0.*Iy;
    W_Ix_r0 = imfilter(Ix.*r0, gauss, 'replicate');
    W_Iy_r0 = imfilter(Iy.*r0, gauss, 'replicate');
end

a11 = 1 + 2*lambda*theta*W_Ix_2;
a12 = 2*lambda*theta*W_Ixy;
a21 = a12;
a22 = 1 + 2*lambda*theta*W_Iy_2;
l_t_2_W_Ix_r0 = 2*lambda*theta*W_Ix_r0;
l_t_2_W_Iy_r0 = 2*lambda*theta*W_Iy_r0;

delta = a11.*a22 - a21.*a12;
%%
for k = 1:settings.its
    %%    
    % 1. update the coupling variable    
    
    b1 = u - l_t_2_W_Ix_r0;            
    b2 = v - l_t_2_W_Iy_r0;
    
    % update u_ and v_        
    deltaU_ = b1.*a22 - b2.*a12;
    deltaV_ = b2.*a11 - b1.*a21;
    
    u_ = deltaU_./delta;
    v_ = deltaV_./delta;
       
    %%  
  % compute the divergence of the dual variable
  % the adjoint of the nabla (derivative) operator = (- divergence) operator
    
  div_u = imfilter(pu(:, :, 1), adjoint_der_mask, 'replicate') + ...
          imfilter(pu(:, :, 2), adjoint_der_mask', 'replicate');
  div_v = imfilter(pv(:, :, 1), adjoint_der_mask, 'replicate') + ...
          imfilter(pv(:, :, 2), adjoint_der_mask', 'replicate');
  
  % update primal variable u
  u = u_ + theta*div_u;
  
  % update primal variable v
  v = v_ + theta*div_v;
  
  % compute nabla(u); the derivative operator  
  ux = imfilter(u, der_mask, 'replicate');
  uy = imfilter(u, der_mask', 'replicate');    
  vx = imfilter(v, der_mask, 'replicate');
  vy = imfilter(v, der_mask', 'replicate');

  % update dual variable; gradient descent
  % p = p_k + tau*nabla(u);
  pu(:, :, 1) = pu(:, :, 1) + tau * ux;
  pu(:, :, 2) = pu(:, :, 2) + tau * uy;
  pv(:, :, 1) = pv(:, :, 1) + tau * vx;
  pv(:, :, 2) = pv(:, :, 2) + tau * vy;
  
  % project the dual variable to ensure the inequality |p| <= D
  % p = p./max(|p|, D) .* D;
  pu(:, :, 1) = pu(:, :, 1)./max(abs(pu(:, :, 1)), D) .* D;
  pu(:, :, 2) = pu(:, :, 2)./max(abs(pu(:, :, 2)), D) .* D;
  pv(:, :, 1) = pv(:, :, 1)./max(abs(pv(:, :, 1)), D) .* D;
  pv(:, :, 2) = pv(:, :, 2)./max(abs(pv(:, :, 2)), D) .* D;
end
