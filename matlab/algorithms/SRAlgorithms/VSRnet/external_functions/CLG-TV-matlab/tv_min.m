% 
% Author: Marius Drulea
% http://www.cv.utcluj.ro/optical-flow.html
% 
% References
% M. Drulea and S. Nedevschi, "Total variation regularization of 
% local-global optical flow," in Intelligent Transportation Systems (ITSC), 
% 2011 14th International IEEE Conference on, 2011, pp. 318-323.
% 
% Copyright (C) 2011 Technical University of Cluj-Napoca
% 
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

function [u] = tv_min(u0, lambda)
%   The output u approximately minimizes the Rudin-Osher-Fatemi (ROF)
%   denoising model
%
%       Min  TV(u) + 1/(2*lambda)* || u - u0 ||^2_2,
%        u

u = zeros(size(u0));

% initialization of the dual variable
p1 = zeros(size(u0));
p2 = zeros(size(u0));

tau = 1/4;
max_iters = 100;

der_mask = [0 -1 1];
adjoint_der_mask = [-1 1 0];

for i=1:max_iters
    
    % the divergence
    div_p = imfilter(p1, adjoint_der_mask, 'replicate') + ...
        imfilter(p2, adjoint_der_mask', 'replicate');
    
    t = div_p - u0/lambda;
    
    % the derivatives
    tx = imfilter(t, der_mask, 'replicate');
    ty = imfilter(t, der_mask', 'replicate');
    
    denominator = 1 + tau * sqrt(tx.^2 + ty.^2);
    
    % update dual variable; gradient ascent and reprojection
    p1 = (p1 + tau*tx)./denominator;
    p2 = (p2 + tau*ty)./denominator;
    
    % update variable; gradient descent
    u = u0 - lambda*div_p;
end

end