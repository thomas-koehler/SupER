function [I_med, Iwarped] = medfilttemp(LRImages, motionParams)
        
    Iwarped = zeros(size(LRImages));
    for k = 1:size(LRImages,3)
        H = motionParams{k};
        Iwarped(:,:,k) = imtransform(LRImages(:,:,k), maketform('projective', H'), ... 
            'XData', [1 size(LRImages,2)], 'YData', [1 size(LRImages,1)]);
    end
    
    I_med = zeros(size(LRImages,1), size(LRImages,2));
    for y = 1:size(I_med,1)
        for x = 1:size(I_med,2)
            I = Iwarped(y, x, :);
            I_med(y,x) = median(I(I > 0));
        end
    end
    I_med(isnan(I_med)) = 0;