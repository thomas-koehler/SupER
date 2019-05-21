function J = cell2Image(I)

    numChannels = numel(I);
    for channelIdx = 1:numChannels
        J(:,:,channelIdx) = I{channelIdx};
    end