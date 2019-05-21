function saveResultImages(inputDir, datasetConfig, resultDir, compressions, binningFactors, numberOfFrames, numberOfFrames_val, sliding_val, sr_method_val, binning_val, scenes_val, compressions_val)

    % Get configuration for this dataset.
    load([inputDir,'/', datasetConfig, '.mat'], 'nums', 'chars');
    % Get list of available scenes.
    scenes = chars(2:end,1);
    % Get list of available motion types.
    motionTypes = chars(2:end,2);

    % Iterate over compression settings.
    for compressIdx = compressions_val
    
        if isnan( compressions(compressIdx) )
            compress_affix = '';
            compress_folder = 'Uncoded';
        else
            compress_affix = ['QP', num2str(compressions(compressIdx))];
            compress_folder = ['H265', compress_affix];
        end

        % Iterate over all scenes.
        for datasetIdx = scenes_val
            mkdir([resultDir, filesep, scenes{datasetIdx}, filesep, compress_folder, filesep], 'png');
            % Apply super-resolution for the different binning factors.
            for binningFactorIdx = binning_val
                % Iterate over different SR methods.
                for sr_method = sr_method_val
                    % Iterate over different sequence lenghts.
                    for numberOfFramesIdx = numberOfFrames_val
                        % Iterate over different sliding windows.
                        for slidingIdx = sliding_val
                            % Load the ground truth.
                            srFilename = [resultDir, filesep, scenes{datasetIdx}, filesep, compress_folder, filesep, 'mat', filesep, motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr',num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '.mat'];
                            if ~exist(srFilename, 'file')
                                fprintf('SR result not available (%s)\n', srFilename);
                            else
                                % Load the super-resolved image.
                                load(srFilename);

                                % Get method name.
                                srMethodName = fieldnames(srImages);
                                srMethodName = srMethodName{1};
                                SR = getfield(srImages, srMethodName);

                                % Convert to grayscale if desired.
                                if ndims(SR) == 3
                                    SR = SR(:,:,1);
                                end

                                % Align to ground truth if desired and crop
                                % image boundary.
                                SR = alignToGroundTruth(SR, srMethodName, binningFactors(binningFactorIdx));
                                border = 3;
                                SR = SR( (border+1):(end-border), (border+1):(end-border) );

                                imwrite(SR, ...
                                    [resultDir, filesep, scenes{datasetIdx}, filesep, compress_folder, filesep, 'png', filesep, scenes{datasetIdx}, '_', motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr',num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '.png']);
                            end
                        end
                    end
                end
            end
        end
    
    end