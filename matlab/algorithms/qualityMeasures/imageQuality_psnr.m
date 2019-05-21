function qualityMeasure = imageQuality_psnr(sr, gt)
    
    qualityMeasure = psnr(sr, gt);

    