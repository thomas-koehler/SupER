function qualityMeasure = imageQuality_lpips(sr, gt)
    
    % Prepare input images.
    path = [fileparts(which(mfilename)), '/PerceptualSimilarity'];
    cd(path);
    img1 = [path, '/', char(java.util.UUID.randomUUID) '.png'];
    imwrite(sr, img1);
    img2 = [path, '/',  char(java.util.UUID.randomUUID) '.png'];
    imwrite(gt, img2);
    
    % Call LPIPS via Python.
    mod = py.importlib.import_module('lpips');
    py.importlib.reload(mod);
    qualityMeasure = - mod.compute(img1, img2, []);
	
	delete(img1);
	delete(img2);
    cd('..');