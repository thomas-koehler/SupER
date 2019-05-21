% Create winning matrix for SR methods from a given set of image pairs and 
% corresponding votes.
function winningMatrix = createWinningMatrix(imagePairs)
    
    numImagePairs = length(imagePairs);
    numSRMethods = length(SRMethods);
    winningMatrix = zeros(numSRMethods, numSRMethods);
    for imagePairIdx = 1:numImagePairs
    
        if imagePairs(imagePairIdx).isSanityCheck == false                             
            % Get SR methods and vote for the current image pair.
            srMethod1 = imagePairs(imagePairIdx).firstImage.srMethod;
            srMethod2 = imagePairs(imagePairIdx).secondImage.srMethod;
            vote = imagePairs(imagePairIdx).vote;
            
            if vote == 1
                % The first method was chosen over the second one.
                winningMatrix(srMethod1, srMethod2) = winningMatrix(srMethod1, srMethod2) + 1;
            elseif vote == 2
                % The second method was chosen over the first one.
                winningMatrix(srMethod2, srMethod1) = winningMatrix(srMethod2, srMethod1) + 1;
            else
                % The ranking has an invalid value.
                error('Invalid ranking');
            end
            
        end
        % else: The image pair is used as a sanity check.
        
    end