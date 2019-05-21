function [imgs, midres] = scaleup_GR(conf, imgs)

% Super-Resolution Iteration
    fprintf('Scale-Up GR');
    midres = resize(imgs, conf.upsample_factor, conf.interpolate_kernel);
    %interpolated = resize(imgs, conf.scale, conf.interpolate_kernel);
    
    for i = 1:numel(midres)
        features = collect(conf, {midres{i}}, conf.upsample_factor, conf.filters);
        features = double(features);

        % Reconstruct using patches' dictionary and their global projection
        patches = conf.PP * (conf.V_pca'*features);
                
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
