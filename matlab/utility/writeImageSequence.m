% Write image sequence to directory.
function writeImageSequence(imgSeq, dirName, pattern)

    numFrames =  size(imgSeq, 3);
    mkdir(dirName);
    for k = 1:numFrames
        filename = sprintf(pattern, k);
        imwrite(imgSeq(:,:,k), [dirName, '/', filename]);
    end