function grad = mapDataTerm_gradImage(SR, model, LR, W, Wt)

    if isempty(model.photometricParams)
        % Get residual error for super-resolved estimate.
        r = getResidual(SR, LR, W, model.photometricParams);
        % Weight residual error by associated confidence map
        confidence = model.confidence;
        if isempty(confidence)
            % Default: equal confidence for each pixel
            confidence = ones(size(LR));
        end
        if ~isvector(confidence)
            confidence = imageToVector(confidence);
        end
        % Calculate the gradient w.r.t. image pixels of HR image
        if strcmp(model.errorModel, 'l2NormErrorModel') 
            grad = - 2 * (Wt * (confidence .* r));
        elseif strcmp(model.errorModel, 'l1NormErrorModel') 
            grad = - Wt * (confidence .* sign(r));
        else
            % User-defined error model
            [~, g] = model.errorModel(r);
            grad = - Wt * (confidence .* g);
        end       
    else       
        % Calculate the residual using photometric parameters.
        numFrames = size(model.photometricParams.mult, 3);
        numLRPixel = length(LR)/numFrames;
        if isvector(model.photometricParams.mult(:,:,1))
            % Global, affine photometric model
            bm = zeros(size(LR));
            ba = zeros(size(LR));
            for k = 1:numFrames
                bm( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(model.photometricParams.mult(k), numLRPixel, 1);
                ba( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = repmat(model.photometricParams.add(k), numLRPixel, 1);
            end
        else
            % Local (pixel-wise) photometric model
            bm = zeros(size(LR));
            ba = zeros(size(LR));
            for k = 1:numFrames
                bm( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = imageToVector(model.photometricParams.mult(:,:,k));
                ba( ((k-1)*numLRPixel + 1):(k*numLRPixel) ) = imageToVector(model.photometricParams.add(:,:,k));
            end
        end
        r = LR - bm .* (W*SR) - ba;
        % Weight residual error by associated confidence map
        confidence = model.confidence;
        if ~isvector(confidence)
            confidence = imageToVector(confidence);
        end
        if isempty(confidence)
            % Default: equal confidence for each pixel
            confidence = ones(size(LR));
        end
        
        % Calculate the gradient w.r.t. image pixels of HR image taking
        % photometric parameters into account.
%         grad = 0;
%         for k = 1:numFrames
%             m = numLRPixel*(k-1) + 1;
%             %Wkt = Wt(:, m:(m + numLRPixel-1));
%             Wk = W(m:(m + numLRPixel-1), :);
%             ck = confidence(m:(m + numLRPixel-1));
%             rk = r(m:(m + numLRPixel-1));
%             
%             if ~isvector(model.photometricParams.mult(:,:,k))
%                 % Local (pixel-wise) photometric model
%                 bm = imageToVector( model.photometricParams.mult(:,:,k) );
%             else
%                 % Global, affine photometric model
%                 bm = model.photometricParams.mult(k);
%             end
%         end
            
            if strcmp(model.errorModel, 'l2NormErrorModel') 
                %grad = grad - 2 * Wkt * (bm .* ck .* rk);
                grad = (-2 * (bm .* confidence .* r)' * W)';
                %grad = grad + g';
            elseif strcmp(model.errorModel, 'l1NormErrorModel')
                %grad = grad - Wkt * (bm .* ck .* sign(rk));
                grad = - Wt * (bm .* confidence .* sign(r));
                %grad = grad + g';
            else
                % User-defined error model
                [~, g] = model.errorModel(rk);
                %grad = grad - Wkt * (bm .* ck .* g);
                grad = - Wt * (bm .* confidence .* g);
                %grad = grad + g';
            end
        end      
    end