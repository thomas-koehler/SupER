function J = image2Cell(I)

    numChannels = size(I,3);
    for channelIdx = 1:numChannels
        J{channelIdx} = squeeze(I(:,:,channelIdx));
    end