function [imgs, interpolated] = scaleup_Zeyde(conf, imgs)

% Super-Resolution Iteration
for j = 1:conf.level
    fprintf('Scale-Up Zeyde et al. #%d', j);
    midres = resize(imgs, conf.upsample_factor, conf.interpolate_kernel);
    interpolated = resize(imgs, conf.scale, conf.interpolate_kernel);
    
    for i = 1:numel(midres)
        features = collect(conf, {midres{i}}, conf.upsample_factor, conf.filters);
        features = double(features);
        % Encode features using OMP algorithm      

        coeffs = omp(double(conf.dict_lores), conf.V_pca' * features, [], 3);                        

        % Reconstruct using patches' dictionary
        patches = conf.dict_hires * full(coeffs); 
        
        % Add low frequencies to each reconstructed patch
        patches = patches + collect(conf, {interpolated{i}}, conf.scale, {});

        % Combine all patches into one image
        img_size = size(imgs{i}) * conf.scale;
        grid = sampling_grid(img_size, ...
            conf.window, conf.overlap, conf.border, conf.scale);
        result = overlap_add(patches, img_size, grid);
        imgs{i} = result; % for the next iteration
        fprintf('.');
    end
end
fprintf('\n');
