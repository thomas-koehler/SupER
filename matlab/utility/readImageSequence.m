% Read image sequence from directory.
function imSeq = readImageSequence(dirName, pattern, roi)

    % Get image filenames from directory.
    filenames = dir( [dirName, filesep, pattern] );
    numFrames = length(filenames);
    
    % Read first image to allocate memory for image sequence. All images
    % must be of the same dimension.
    firstImg = imread( [dirName, filesep, filenames(1).name] );
    if ismatrix(firstImg)
        imSeq(:,:,1) = firstImg;
    else
        imSeq(:,:,:,1) = firstImg;
    end
    
    % Read other images of the sequence.
    for k = 2:numFrames
        if ismatrix(firstImg)
            imSeq(:,:,k) = imread( [dirName, filesep, filenames(k).name] );
        else
            imSeq(:,:,:,k) = imread( [dirName, filesep, filenames(k).name] );
        end
    end
        
    if nargin > 2 && (~isempty(roi))
        % Crop images according to specified ROI.
        rowStart = roi(1);
        colStart = roi(2);
        h = roi(3);
        w = roi(4);
        if ismatrix(firstImg)
            imSeq = imSeq(rowStart:(rowStart + h - 1), colStart:(colStart + w - 1), :);
        else
            imSeq = imSeq(rowStart:(rowStart + h - 1), colStart:(colStart + w - 1), :, :);
        end
    end