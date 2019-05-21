
function [u v] = coarse_to_fine(I1, I2, settings, show_flow, h)

[M N] = size(I1);

% computes the maximum number of pyramid levels; the coarsest image should
% have a width or height around 10
pyramid_levels = min(...
    ceil(log(10/M)/log(settings.pyramid_factor)), ...
    ceil(log(10/N)/log(settings.pyramid_factor)));

pyrI1 = cell(pyramid_levels, 1);
pyrI2 = cell(pyramid_levels, 1);

pyrI1{1} = I1;
pyrI2{1} = I2;

% build the pyramids
for i = 2:pyramid_levels
  pyrI1{i} = imresize(I1, (settings.pyramid_factor)^(i-1), settings.resampling_method);
  pyrI2{i} = imresize(I2, (settings.pyramid_factor)^(i-1), settings.resampling_method);  
end

% start coarse to fine processing
for level = pyramid_levels:-1:1;
  
  [M N] = size(pyrI1{level});
  if level == pyramid_levels
 
    % initialization  
    u = zeros(M, N);
    v = zeros(M, N);
       
    pu = zeros(M, N, 2);
    pv = zeros(M, N, 2);
    
  else    
    % previous dimensions
    [Mp Np] = size(pyrI1{level+1});  
    
    % upsample the flow to next level
    u = imresize(u, [M N], settings.resampling_method) * N/Np;    
    v = imresize(v, [M N], settings.resampling_method) * M/Mp;

    pu_tmp = pu;
    pv_tmp = pv;
    
    pu = zeros(M, N, 2);
    pv = zeros(M, N, 2);
    
    for i=1:2
      pu(:,:,i) = imresize(pu_tmp(:,:,i), [M N], settings.resampling_method);
      pv(:,:,i) = imresize(pv_tmp(:,:,i), [M N], settings.resampling_method);
    end
  end  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % solve the optical flow on the current level
  [u, v, pu, pv] = solve_flow_on_level(u, v, pu, pv, pyrI1{level}, pyrI2{level}, settings, level, show_flow, h); 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end