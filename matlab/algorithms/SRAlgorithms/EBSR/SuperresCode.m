function [SupResol] = SuperresCode(Low, MFactor, ColorProcMethod, Model)

if nargin < 4
    load MatlabR2007aSupResModel.mat;
end
if nargin < 3
    ColorProcMethod = 'L';
end

BoundarySize = 9;
warning off;
%BiC = imresize(Low,MFactor, 'bicubic');
% MAGI-STUFF-START
Low_tmp = im2double(Low);
BiC_tmp = lmsSR_interpolate2D(Low_tmp,[MFactor, MFactor],'cubic');
BiC = im2uint8(BiC_tmp);
% MAGI-STUFF-END
warning on;
BiC = padarray(BiC, [BoundarySize,BoundarySize], 'symmetric','both');
[SupResol] = SuperresMexInt(BiC, MFactor, ColorProcMethod, Model);
SupResol = SupResol(BoundarySize+1:end-BoundarySize,BoundarySize+1:end-BoundarySize,:);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SupResol] = SuperresMexInt(BiC, MFactor, ColorProcMethod, Model)

[IHeight,IWidth,ColorDim] = size(BiC);

if ColorDim > 1 %%% if color
    if ColorProcMethod == 'C'
    %%% proc. each RGB channel independently
        RBiC = BiC(:,:,1);
        GBiC = BiC(:,:,2);
        BBiC = BiC(:,:,3);
        SupResol = zeros(size(BiC));
        [SupResol(:,:,1)] = SuperresMexInt(RBiC, MFactor, ColorProcMethod, Model);
        [SupResol(:,:,2)] = SuperresMexInt(GBiC, MFactor, ColorProcMethod, Model);
        [SupResol(:,:,3)] = SuperresMexInt(BBiC, MFactor, ColorProcMethod, Model);
    %%% proc. each RGB channel independently 
    else
    %%% proc. luminance component only
        CBiC = double(BiC)/255;
        YIQ = rgb2ntsc(CBiC);
        Lum = YIQ(:,:,1);
        [SupResolLum] = SuperresMexInt(Lum*255, MFactor, ColorProcMethod, Model);
        YIQ(:,:,1) = SupResolLum/255;
        SupResol = ntsc2rgb(YIQ);
        SupResol = SupResol*255;
    %%% proc. luminance component only
    end
else
    BiC = double(BiC)/255*2-1;
    if MFactor == 2
        [SupResol] = SuperresCodeMex(BiC, Model.M2, MFactor);
    elseif MFactor == 3
        [SupResol] = SuperresCodeMex(BiC, Model.M3, MFactor);
    elseif MFactor == 4
        [SupResol] = SuperresCodeMex(BiC, Model.M4, MFactor);
    else
        display('Mag. factor should be [2,3,4].');
        return;
    end
    SupResol = (SupResol+1)/2*255;
end
