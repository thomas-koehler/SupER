function [imgs, midres] = scaleup_NE_LLE(conf, imgs, K)

% Super-Resolution Iteration
    fprintf('Scale-Up NE+LLE');
    midres = resize(imgs, conf.upsample_factor, conf.interpolate_kernel);    
    
    for i = 1:numel(midres)
        features = collect(conf, {midres{i}}, conf.upsample_factor, conf.filters);
        features = double(features);
        
        features = conf.V_pca'*features;
        
        D = abs(conf.dict_lores'*features);
        patches = zeros(size(conf.dict_hires,1), size(features,2));
        tol = 0.0001;
        for t = 1:size(features,2)
            [val idx] = sort(D(:,t),'descend');      
            
            % Use K atom neighbors and obtain the LLE coefficients
            z = conf.dict_lores(:,idx(1:K))-repmat(features(:,t),1,K); % shift ith pt to origin
            C = z'*z;                                        % local covariance
            if trace(C)==0
                C = C + eye(K,K)*tol;                   % regularlization
            else
                C = C + eye(K,K)*tol*trace(C);
            end
            coeffs = C\ones(K,1);                           % solve C*u=1
            coeffs = coeffs/sum(coeffs);                  % enforce sum(u)=1
            
            % Reconstruct using patches' dictionary            
            patches(:,t) = conf.dict_hires(:,idx(1:K))*coeffs;
        end       
                
        % Add low frequencies to each reconstructed patch        
        patches = patches + collect(conf, {midres{i}}, conf.scale, {});
        
        % Combine all patches into one image
        img_size = size(imgs{i}) * conf.scale;
        grid = sampling_grid(img_size, ...
            conf.window, conf.overlap, conf.border, conf.scale);
        result = overlap_add(patches, img_size, grid);
        imgs{i} = result; % for the next iteration
        fprintf('.');
    end
fprintf('\n');
