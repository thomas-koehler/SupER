% Run sanity checks on a given set of image pairs.
function [sanityCheckPassed, sanityCheckFailed, failedChecks] = performSanityCheck(imagePairs, maxSanityCheckFails)

    numWorkers = length(imagePairs);
    sanityCheckPassed = [];
    sanityCheckFailed = [];
    for workerIdx = 1:numWorkers
    
        [sanityCheck, failedChecks(:,workerIdx)] = performSanityCheckForWorker(imagePairs{workerIdx}, maxSanityCheckFails);
        if sanityCheck == true
            sanityCheckPassed = cat(1, sanityCheckPassed, workerIdx);
        else
            sanityCheckFailed = cat(1, sanityCheckFailed, workerIdx);
        end
 
    end
    
function [sanityCheckPassed, numChecksFailed] = performSanityCheckForWorker(imagePairs, maxSanityCheckFails)
    
    numChecksFailed = zeros(length(imagePairs), 1);
    sanityCheckPassed = true;
    for imagePairIdx = 1:length(imagePairs)
        
        % Check if the current pair is used as a sanity check.
        if imagePairs(imagePairIdx).isSanityCheck == true
            
            % Check if the current pair passes the sanity check.
            if ~isempty(strfind(imagePairs(imagePairIdx).firstImage.name, '_good')) && imagePairs(imagePairIdx).vote == 2
                % It failed the sanity check.
                numChecksFailed(imagePairIdx) = 1;
            end
            if ~isempty(strfind(imagePairs(imagePairIdx).firstImage.name, '_bad')) && imagePairs(imagePairIdx).vote == 1
                % It failed the sanity check.
                numChecksFailed(imagePairIdx) = 1;
            end
            
        end
        
    end
    
    if sum(numChecksFailed) > maxSanityCheckFails
        sanityCheckPassed = false;
    end