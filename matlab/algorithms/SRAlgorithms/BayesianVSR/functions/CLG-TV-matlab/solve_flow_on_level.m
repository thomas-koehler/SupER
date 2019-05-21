
function [u, v, pu, pv] = solve_flow_on_level(u, v, pu, pv, I1, I2, settings, level, show_flow, h)

[M N] = size(I1);

[idx idy] = meshgrid(1:N, 1:M);

if (settings.use_diffusion == 1)    
    % compute the diffusion coefficient
    D = compute_diffusion_coefficient(I1);
else
    D = ones(M, N);
end

if (settings.use_ROF_texture == 1)
    % apply ROF denoising and and substract the original
    I1 = compute_ROF_texture(I1, settings.ROF_texture_factor);
    I2 = compute_ROF_texture(I2, settings.ROF_texture_factor);
end

if show_flow == 1
    set(0,'CurrentFigure', h);
    subplot(2,2,1), imshow(I1), title('I1');
    subplot(2,2,2), imshow(I2), title('I2');
    drawnow;
end
  
% five-point mask for computing spatial derivatives
mask = [1 -8 0 8 -1]/12;

I1x = imfilter(I1, mask, 'replicate');
I1y = imfilter(I1, mask', 'replicate');

I2x = imfilter(I2, mask, 'replicate');
I2y = imfilter(I2, mask', 'replicate');

% for each level, apply the warping technique
for i=1:settings.warps
    
    % apply median filtering
    u0 = medfilt2(u, [3 3], 'symmetric');
    v0 = medfilt2(v, [3 3], 'symmetric');
    
    idxx = idx + u0;
    idyy = idy + v0;
    
    % boundary handling
    out = (idxx < 1) | (idxx > N) | (idyy < 1) | (idyy > M);
        
%     % boundary handling
%     idxx = max(1, idxx);
%     idyy = max(1, idyy);   
%     idxx = min(size(u, 2), idxx);
%     idyy = min(size(u, 1), idyy);
    
    % shift (warp) the second image
    I2_w = interp2(I2, idxx, idyy, settings.interpolation_method);
    I2x_w = interp2(I2x, idxx, idyy, settings.interpolation_method);
    I2y_w = interp2(I2y, idxx, idyy, settings.interpolation_method);
    
    % mix the derivatives
    Ix = 0.5*(I1x + I2x_w);
    Iy = 0.5*(I1y + I2y_w);
    
    It = I2_w  - I1;             
    
    % boundary handling
    Ix(out) = 0; 
    Iy(out) = 0; 
    It(out) = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    % solve anisotropic CLG_TV optical flow
    [u, v, pu, pv] = solve_clg_tv_equation(u, v, u0, v0, pu, pv, ...
        I1, Ix, Iy, It, D, settings);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if show_flow == 1                
        % find robust max flow for better visualization
        magnitude = (u.^2 + v.^2).^0.5;
        max_flow = prctile(magnitude(:), 95);
        
        tmp = zeros(M,N,2);
        tmp(:,:,1) = min(max(u,-max_flow),max_flow);
        tmp(:,:,2) = min(max(v,-max_flow),max_flow);
                
        set(0,'CurrentFigure', h), subplot(2,2, [3 4]), imshow(uint8(flowToColor(tmp)));
        title(['Flow at level ', int2str(level), ', warp ' int2str(i)]);
        drawnow;
    end
end