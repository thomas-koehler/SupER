function [lores hires] = collectSamplesScales(conf, ohires, numscales, scalefactor)

lores = [];
hires = [];

for scale = 1:numscales
    sfactor = scalefactor^(scale-1);
    chires = resize(ohires, sfactor, 'bicubic');
    
    chires = modcrop(chires, conf.scale); % crop a bit (to simplify scaling issues)
    % Scale down images
    clores = resize(chires, 1/conf.scale, conf.interpolate_kernel);
    midres = resize(clores, conf.upsample_factor, conf.interpolate_kernel);
    features = collect(conf, midres, conf.upsample_factor, conf.filters);
    clear midres

    interpolated = resize(clores, conf.scale, conf.interpolate_kernel);
    clear clores
    patches = cell(size(chires));
    for i = 1:numel(patches) % Remove low frequencies
        patches{i} = chires{i} - interpolated{i};
    end
    clear chires interpolated

    hires = [hires collect(conf, patches, conf.scale, {})];
    
    lores = [lores conf.V_pca' * features];
end