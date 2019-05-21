function [imgs, midres] = scaleup_ANR_time(conf, imgs)

% Super-Resolution Iteration
    fprintf('Scale-Up ANR');
    midres = resize(imgs, conf.upsample_factor, conf.interpolate_kernel);    
    
    for i = 1:numel(midres)
        features = collect(conf, {midres{i}}, conf.upsample_factor, conf.filters);
        features = double(features);

        % Reconstruct using patches' dictionary and their anchored
        % projections
                
        features = conf.V_pca'*features;
        
        patches = zeros(size(conf.PP,1),size(features,2));
        blocksize = 50000; %if not sufficient memory then you can reduce the blocksize
        
%         if size(features,2) < blocksize
%             D = abs(conf.pointslo'*features); 
%             %D = conf.pointslo'*features; 
%             %D = conf.pointsloPCA*features; 
%             [val idx] = max(D);            
% 
%             %if number of patches >> number of atoms in dictionary then you
%             %can use the commented code for speed
%             
% %             uidx = unique(idx);
% %             for u = 1: numel(uidx)
% %                 fidx = find(idx==uidx(u));                
% %                 patches(:,fidx) = conf.PPs{uidx(u)}*features(:,fidx);
% %             end
%             for l = 1:size(features,2)            
%                 patches(:,l) = conf.PPs{idx(l)} * features(:,l);
%             end
%         else            
%             
%             for b = 1:blocksize:size(features,2)
%                 if b+blocksize-1 > size(features,2)
%                     D = abs(conf.pointslo'*features(:,b:end));
%                     %D = conf.pointslo'*features(:,b:end);
%                 else
%                     D = abs(conf.pointslo'*features(:,b:b+blocksize-1));                 
%                     %D = conf.pointslo'*features(:,b:b+blocksize-1);                 
%                 end
%                 [val idx] = max(D);            
% 
% %                 uidx = unique(idx);
% %                 for u = 1: numel(uidx)
% %                     %fidx = find(idx==u);
% %                     fidx = find(idx==uidx(u));
% %                     patches(:,b-1+fidx) = conf.PPs{uidx(u)}*features(:,b-1+fidx);
% %                 end
%                 for l = 1:size(idx,2)
%                     patches(:,b-1+l) = conf.PPs{idx(l)} * features(:,b-1+l);
%                 end
%                 
%             end
%         end
        
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
