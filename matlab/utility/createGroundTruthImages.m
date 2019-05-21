% This function calculates the ground truth images for a given dataset by
% averaging multiple consecutive frames at the stop-motion time steps.
function groundTruthSequence = createGroundTruthImages(datasetDir, type)

    % Get all files in the dataset directory.
    files = dir([datasetDir, '/*.', type]);
    numFiles = length(files);
    fileIdx = 1;
    groundTruthIdx = 1;
    while fileIdx <= numFiles
        % Read the first frame of the k-th time step.
        filename = files(fileIdx).name;
        frames(:,:,1) = im2double( imread([datasetDir, '/', filename]) );
        
        % Read all remaining frames of the k-th time step.
        for frameIdx = 1:30
            % Get filename and extract the frame number.
            if fileIdx + frameIdx > numFiles
                % We reached the end of the file list.
                break;
            end
            filename = files(fileIdx + frameIdx).name;
            [~, filenameWithoutEx, ~] = fileparts(filename);
            frameNumber = str2num( filenameWithoutEx(end-1:end) ); %#ok<ST2NM>
            
            if frameNumber ~= 0
                % New frame for the current time step.
                frames(:,:,frameIdx+1) = im2double( imread([datasetDir, '/', filename]) ); %#ok<AGROW>
            else
                % We reached the last frame of the current time step.
                break;
            end
        end
        
        % Calculate ground truth image of the k-th time step by the
        % temporal mean (or median) of all corresponding frames.
        groundTruthSequence(:,:,groundTruthIdx) = mean(frames, 3); %#ok<AGROW>
        
        fileIdx = fileIdx + frameIdx;
        groundTruthIdx = groundTruthIdx + 1;
    end