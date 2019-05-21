function processDatasets(inputDir, datasetConfig, resultDir, binningFactors, numberOfFrames, startReferenceFrame, numberOfFrames_val, sliding_val, sr_method_val, binning_val, scenes_val, compressions_val, numTimingTests, simulate)

    if nargin < 13
        % Only one sample for time measurements.
        numTimingTests = 1;
    else
        disp('Running timing tests only...');
    end

    if nargin < 14
        simulate = false;
    end

    % Get configuration for this evaluation.
    load([inputDir,'/', datasetConfig, '.mat']);

    % Iterate over compression settings.
    for compressIdx = compressions_val

        % Get result directory from compression setting.
        if isnan(compressIdx)
            compress_affix = '';
            compressionDir = 'Uncoded';
        else
            compress_affix = ['QP', num2str(compressIdx)];
            compressionDir = ['H265', compress_affix];
        end

        % Iterate over all scenes.
        for datasetIdx = scenes_val

            % Prepare result directory for current dataset.
            if ~exist([resultDir, filesep,evalData.scenes{datasetIdx}], 'dir')
                mkdir(resultDir, evalData.scenes{datasetIdx});
            end
            if ~exist([resultDir, filesep,evalData.scenes{datasetIdx}, filesep, compressionDir], 'dir')
                mkdir([resultDir, filesep,evalData.scenes{datasetIdx}], compressionDir);
            end
            if ~exist([resultDir, filesep,evalData.scenes{datasetIdx}, filesep,compressionDir, filesep, 'mat'], 'dir')
                mkdir([resultDir, filesep,evalData.scenes{datasetIdx}, filesep,compressionDir], 'mat');
            end

            % Read image data for current scene and motion type.
            imageDataset = readDatasetWithMultipleBinningFactors([inputDir, filesep, evalData.scenes{datasetIdx}, filesep, evalData.motionTypes{datasetIdx}], [1, binningFactors], compress_affix, 'png', false, simulate);

            % Select the ROI for this evaluation.
            imageDataset = selectROI(imageDataset, [1, binningFactors], evalData.ROI(datasetIdx, :));

            % Iterate over the different binning factors.
            for binningFactorIdx = binning_val
                % Iterate over different SR methods.
                for sr_method = sr_method_val
                    % Iterate over different sequence lenghts.
                    for numberOfFramesIdx = numberOfFrames_val
                        % Iterate over different sliding windows.
                        for slidingIdx = sliding_val

                            if numTimingTests == 1 && exist([resultDir, filesep, evalData.scenes{datasetIdx}, filesep, compressionDir, filesep, 'mat', filesep, evalData.motionTypes{datasetIdx}, '_bin', num2str(binningFactors(binningFactorIdx)), '_sr', num2str(sr_method), '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '.mat'], 'file')
                                disp('Output already calculated... SKIPPING!');
                            else
                                % Apply current SR algorithm.
                                timesTotal = zeros(numTimingTests, 1);
                                timesME = zeros(numTimingTests, 1);
                                timesSR = zeros(numTimingTests, 1);
                                for time_measure = 1:numTimingTests
                                    tTotal = tic;
                                    [srImages, timeME, timeSR] = runSRAlgorithm(imageDataset.(['Bin', num2str( binningFactors(binningFactorIdx) )]), imageDataset.groundTruth, binningFactors(binningFactorIdx), startReferenceFrame, numberOfFrames(numberOfFramesIdx,binningFactorIdx), slidingIdx, sr_method);

                                    % Capture run times.
                                    timesTotal(time_measure) = toc(tTotal);
                                    timesME(time_measure) = timeME;
                                    timesSR(time_measure) = timeSR;
                                end

                                % Save result for current dataset.
                                if numTimingTests > 1
                                    save([resultDir,filesep,evalData.scenes{datasetIdx}, filesep, compressionDir,filesep, 'mat', filesep, evalData.motionTypes{datasetIdx},'_bin', num2str(binningFactors(binningFactorIdx)), '_sr', num2str(sr_method),'_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'), '_times.mat'], 'timesTotal', 'timesME', 'timesSR');
                                else
                                    save([resultDir,filesep,evalData.scenes{datasetIdx}, filesep, compressionDir, filesep, 'mat', filesep, evalData.motionTypes{datasetIdx},'_bin', num2str(binningFactors(binningFactorIdx)), '_sr',num2str(sr_method),'_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), '_win', num2str(slidingIdx,'%02d'),'.mat'], 'srImages');
                                end
                            end
                        end
                    end
                end
            end
        end
    end