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

function I = compute_ROF_texture(I, factor)
   Is = tv_min(I, 1/8);
   I = I - factor*Is;
end