    function srResults = getQualityMeasuresFromResults(resultDir, scenes, motionTypes, compressionLevel, binningFactor, srMethods, numberOfFrames, slidingWindow, qm)

    if nargin < 2 || isempty(scenes)
        % Get list of scenes.
        sceneDirs = dir(resultDir);
        scenes = {};
        for sceneIdx = 1:length(sceneDirs)
            s = sceneDirs(sceneIdx).name;
            if ~sceneDirs(sceneIdx).isdir
                continue;
            end
            if s(1) == '.'
                continue;
            end
            scenes = cat(1, scenes, s);
        end
    end

    if nargin < 3 || isempty(motionTypes)
        motionTypes = {'*'};
    end

    if nargin < 4 || isempty(compressionLevel)
        compressionLevel = {'Uncoded'};
    end
    
    if nargin < 5 || isempty(binningFactor)
        binningFactor = [2 3 4];
    end
        
    if nargin < 6 || isempty(srMethods)
        srMethods = 1:length(SRMethods);
    end

    if nargin < 7 || isempty(numberOfFrames)
        numberOfFrames = [5 11 17];
    end

    if nargin < 8 || isempty(slidingWindow)
        slidingWindow = 1;
    end

    if nargin < 9 || isempty(qm)
        qm = 1:length(qualityMeasures);
    end

    resultIdx = 1;
    s = struct('scene', [], 'compressionLevel', [], 'motionType', [], 'binningFactor', [], 'srMethod', [], 'numberOfFrames', [], 'slidingWindow', []);
    for qualityMeasureIdx = 1:length(qm)
        qualityMeasures_all = qualityMeasures;
        measureName = qualityMeasures_all{qm(qualityMeasureIdx)};
        s.(measureName) = [];
    end
    srResults(1:(length(scenes)*length(compressionLevel)*length(motionTypes)*length(binningFactor)*length(srMethods)*size(numberOfFrames,1)*length(slidingWindow))) = s;
    for sceneIdx = 1:length(scenes)     
        for compressionLevelIdx = 1:length(compressionLevel)
            for motionTypeIdx = 1:length(motionTypes)
                for binningFactorIdx = 1:length(binningFactor)
                    for srMethodIdx = 1:length(srMethods)
                        for numberOfFramesIdx = 1:size(numberOfFrames,1)
                            for slidingWindowIdx = 1:length(slidingWindow)
                                
                                % Capture information for the current SR
                                % result.
                                srResults(resultIdx).scene = scenes{sceneIdx};
                                srResults(resultIdx).compressionLevel = compressionLevel{compressionLevelIdx};
                                srResults(resultIdx).motionType = motionTypes{motionTypeIdx};
                                srResults(resultIdx).binningFactor = binningFactor(binningFactorIdx);
                                srResults(resultIdx).srMethod = lower( getSRMethodNameForIndex(srMethods(srMethodIdx)) );
                                srResults(resultIdx).numberOfFrames = numberOfFrames(numberOfFramesIdx,binningFactorIdx);
                                srResults(resultIdx).slidingWindow = slidingWindow(slidingWindowIdx);
                                
                                % Get quality measures for the current SR
                                % result.
                                for qualityMeasureIdx = 1:length(qm)
                                   
                                    % Assemble filename for quality
                                    % measure.
                                    filename = [resultDir, filesep, ...
                                        scenes{sceneIdx}, filesep, ...
                                        compressionLevel{compressionLevelIdx}, filesep, ...
                                        'quality_qm', num2str(qm(qualityMeasureIdx)), filesep, ...
                                        motionTypes{motionTypeIdx}, ...
                                        '_bin', num2str(binningFactor(binningFactorIdx)), ...
                                        '_sr', num2str(srMethods(srMethodIdx)), ...
                                        '_f', num2str(numberOfFrames(numberOfFramesIdx,binningFactorIdx)), ...
                                        '_win', num2str(slidingWindow(slidingWindowIdx),'%02d'), ...
                                        '_qm', num2str(qm(qualityMeasureIdx)), '.mat'];
                                    
                                    % Load quality measure from file.
                                    if ~exist(filename, 'file')
                                        error('Quality measure file %s does not exist', filename);
                                    end
                                    load(filename);
                                    
                                    % Capture quality measure.
                                    qualityMeasures_all = qualityMeasures;
                                    measureName = qualityMeasures_all{qm(qualityMeasureIdx)};
                                    if isempty(qualityMeasure.(measureName))
                                        error('Quality measure %s is invalid', filename);
                                    end
                                    srResults(resultIdx).(measureName) = qualityMeasure.(measureName);       
                                    
                                    clear 'qualityMeasure' 'filename'
                                    
                                end
                                resultIdx = resultIdx + 1;
                            end
                        end
                    end
                end
            end
        end
    end