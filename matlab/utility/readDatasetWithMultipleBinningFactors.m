% Read a dataset captured at multiple binning factors and compression
% levels from a given directory. If simulate=true, low-resolution images
% are simulated from 1x1 binning (ground truth) data via bicubic
% downscaling.
function imageDataset = readDatasetWithMultipleBinningFactors(datasetDir, factors, compress_affix, type, createGroundTruth, simulate)

    if nargin < 4
        type = 'png';
    end
    if nargin < 5
        createGroundTruth = false;
    end
    
    % Read data for the different binning factors.
    for binningFactorIdx = 1:length(factors)
                
        if factors(binningFactorIdx) == 1 % No adaptation required for compression
            if createGroundTruth
                % Create the ground truth images by averaging over sequences of 
                % consecutive frames.
                imageDataset.groundTruth = createGroundTruthImages([datasetDir, '/Bin', num2str( factors(binningFactorIdx) )], type);
            else
                % Read the ground truth from the given directory.
                frames = readImageSequence([datasetDir, '/Bin1'], ['*.', type]);
                if ~isa(frames, 'double')
                    % Convert to double.
                    frames = double(frames) / 255;
                end
                imageDataset.groundTruth = frames;
            end
        else % Adaptations required for compression
            if simulate
                gt = imageDataset.groundTruth;
                frames = zeros(size(gt,1) / factors(binningFactorIdx), size(gt,2) / factors(binningFactorIdx));
                for k = 1:size(gt,3)
                    frames(:,:,k) = imresize(gt(:,:,k), 1 / factors(binningFactorIdx));
                end
                imageDataset.(['Bin', num2str( factors(binningFactorIdx) )]) = frames;
            else
                % Read image sequence associated with the current binning factor.
                frames = readImageSequence([datasetDir, '/Bin', num2str( factors(binningFactorIdx) ),compress_affix], ['*.', type]);
                if ~isa(frames, 'double')
                    % Convert to double.
                    frames = double(frames) / 255;
                end
                imageDataset.(['Bin', num2str( factors(binningFactorIdx) )]) = frames;
            end
        end
        
    end