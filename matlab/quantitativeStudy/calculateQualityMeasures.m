function calculateQualityMeasures(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, numberOfFrames_val, sliding_val, sr_method_val, binning_val, scenes_val, compressions_val, measure_val, border)

    % Get configuration for this dataset.
    load([inputDir,'/', datasetConfig, '.mat']);

    % Iterate over compression settings.
    for compressIdx = compressions_val

        if isnan(compressIdx)
            compress_folder = 'Uncoded';
        else
            compress_affix = ['QP', num2str(compressIdx)];
            compress_folder = ['H265', compress_affix];
        end

        % Iterate over all scenes.
        for datasetIdx = scenes_val
            % Iterate over the different binning factors.
            for binningFactorIdx = binning_val
                % Iterate over different SR methods.
                for sr_method = sr_method_val

                    if sr_method == 0
                        continue;
                    end

                    % Iterate over different sequence lengths.
                    for numberOfFramesIdx = numberOfFrames_val
                        % Iterate over different sliding windows.
                        for slidingIdx = sliding_val

                            gtFilename = [resultDir, filesep, evalData.scenes{datasetIdx}, filesep, 'Uncoded', filesep, 'mat', filesep, evalData.motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr0', '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '.mat'];
                            srFilename = [resultDir ,filesep, evalData.scenes{datasetIdx}, filesep, compress_folder,filesep, 'mat', filesep, evalData.motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr', num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '.mat'];
                            if ~exist(gtFilename, 'file') || ~exist(srFilename, 'file')
                                fprintf('Ground truth and result not available (%s, %s)\n', gtFilename, srFilename);
                            else
                                % Calculate the different quality measures.
                                groundTruth = [];
                                SR = [];
                                SR_aligned = [];
                                qualityMeasuresVec = qualityMeasures;
                                for measureIdx = measure_val                         
                                    % Prepare result directory for current quality metric
                                    if ~exist([resultDir, filesep,evalData.scenes{datasetIdx}, filesep,compress_folder, filesep,'quality_qm', num2str(measureIdx)], 'dir')
                                        mkdir([resultDir, filesep,evalData.scenes{datasetIdx}, filesep,compress_folder], ['quality_qm', num2str(measureIdx)]);
                                    end

                                    if exist([resultDir, filesep, evalData.scenes{datasetIdx}, filesep, compress_folder, filesep, 'quality_qm', num2str(measureIdx), filesep,evalData.motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr',num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '_qm', num2str(measureIdx), '.mat'],'file')
                                        disp('Quality metric already calculated!');
                                    else
                                        if isempty(groundTruth)
                                            % Load the ground truth.
                                            load(gtFilename);
                                            groundTruth = srImages.groundTruth;  
                                        end
                                        
                                        if isempty(SR)
                                            % Load the SR image.
                                            load(srFilename);
                                            srMethodName = fieldnames(srImages);
                                            srMethodName = srMethodName{1};
                                            SR = getfield(srImages, srMethodName);    
                                        end
                                        
                                        % Align SR image to the ground truth if
                                        % desired (depends on the SR method).
                                        if isempty(SR_aligned)
                                            SR_aligned = alignToGroundTruth(SR, sr_method, binningFactors(binningFactorIdx));
                                        end
                                        
                                        % Calculate the quality measure.
                                        qualityMeasure = calculateQualityMeasureForImage(SR_aligned, groundTruth, qualityMeasuresVec{measureIdx}, border);
                                        save([resultDir, filesep, evalData.scenes{datasetIdx}, filesep, compress_folder, filesep, 'quality_qm', num2str(measureIdx), filesep, evalData.motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr',num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '_qm', num2str(measureIdx), '.mat'], 'qualityMeasure');
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

end

function sr = alignToGroundTruth(sr, srMethodIdx, binningFactor)
    
    srMethods = SRMethods;
    if ~ismatrix(sr)
        sr = sr(:,:,1);
    end
    sr = double(sr);
    
    if strcmp(srMethods(srMethodIdx).name, 'vsrnet')
        % Scale intensities to [0, 1].
        sr = sr / 255;
    end
    
    if strcmp(srMethods(srMethodIdx).pixelSampling, 'topLeft')
        % Geometric alignment of SR image to ground truth for algorithms
        % that use the top left corner for pixel sampling.
        [x_mesh, y_mesh] = meshgrid(1:size(sr, 2), 1:size(sr,1));
        x_mesh_shift = x_mesh - (binningFactor - 1) / 2;
        y_mesh_shift = y_mesh - (binningFactor - 1) / 2;
        sr = griddata(x_mesh, y_mesh, sr, x_mesh_shift, y_mesh_shift, 'cubic');
    end
    
end

function qualityMeasure = calculateQualityMeasureForImage(SR, groundTruth, qualityMeasureName, border)

    % Crop boundary of ground truth and super-resolved image.
    groundTruth = groundTruth( (border+1):(end-border), (border+1):(end-border) );
    SR = SR( (border+1):(end-border), (border+1):(end-border) );

    % Calculate the desired measure.
    qualityMeasure.(qualityMeasureName) = callQualityMeasure(SR, groundTruth, qualityMeasureName);

end
