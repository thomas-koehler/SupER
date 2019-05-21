function qualityMeasure = imageQuality_ssim(sr, gt)
    
    qualityMeasure = ssim(sr, gt);