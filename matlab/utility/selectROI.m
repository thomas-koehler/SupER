% Select a region of interest for a given dataset at multiple resolution
% levels.
function imageDataset = selectROI(imageDataset, factors, ROI)

    for binningFactorIdx = 1:length(factors)
       
        s = factors(binningFactorIdx);
        
        if factors(binningFactorIdx) == 1
            % Extract the given ROI form the ground truth data.
            imageDataset.groundTruth = imageDataset.groundTruth(ROI(2):(ROI(2) + ROI(4) - 1), ROI(1):ROI(1) + ROI(3) - 1, :);
        else
            frames = imageDataset.(['Bin', num2str( factors(binningFactorIdx) )]);
            % Re-calculate ROI for the current binning factor.
            width = ceil(ROI(3) / s);
            hight = ceil(ROI(4) / s);
            x0 = ceil(ROI(1) / s);
            y0 = ceil(ROI(2) / s);
            imageDataset.(['Bin', num2str( factors(binningFactorIdx) )]) = frames(y0:(y0 + hight - 1), x0:(x0 + width - 1), :);
        end
        
    end