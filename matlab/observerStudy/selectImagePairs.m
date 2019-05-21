% Select subset of image pairs for a given scene, motion type, and binning
% factor from the entire set of image pairs.
function imagePairsSel = selectImagePairs(imagePairs, scene, motionType, binningFactor)

    imagePairsSel = cell2mat(imagePairs);
    
    % Select image pairs for the given scene.
    if nargin > 1 && ~isempty(scene)
        imagePairsSel = imagePairsSel( strcmp(scene, {imagePairsSel.scene}) );
    end
    
    % Select image pairs for the given motion type.
    if nargin > 2 && ~isempty(motionType)
        imagePairsSel = imagePairsSel( strcmp(motionType, {imagePairsSel.motionType}) );
    end
    
    % Select image pairs for the given binning factor.
    if nargin > 3 && ~isempty(binningFactor)
        imagePairsSel = imagePairsSel([imagePairsSel.binningFactor] == binningFactor);
    end