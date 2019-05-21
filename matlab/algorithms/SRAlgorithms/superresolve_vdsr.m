function sr_img = superresolve_vdsr(slidingWindows, magFactor)

lIm       = slidingWindows.referenceFrame;
upscaling = magFactor;


% Important Note: Grayscale or YCbCr input data expected!

currentDir = pwd;
cd('../algorithms/SRAlgorithms/VDSR'); % MAGI-FIX

run('matconvnet/matlab/vl_setupnn.m');

model = 'VDSR_CPUonly_SupER.mat';

if isempty(model)
    error('no model');
else
    modelPath = ['VDSR model/',model];
    %gpu = 1;
    gpu = 0; % MAGI-ADAPT
end

model = load(modelPath);
net = model.net;
net = vl_simplenn_tidy(net);

managableMax = 300000;

if isa(lIm,'uint8'),
    lIm = single(lIm)/255;
else
    lIm = single(lIm);
end

lIm = imresize(lIm, upscaling, 'bicubic');

if size(lIm,3)>1
    imlowy = lIm(:,:,1);
    imlowy = max(16.0/255, min(235.0/255, imlowy));
    imlowcb = lIm(:,:,2);
    imlowcr = lIm(:,:,3);
else
    imlowy = lIm;
end

% Perform actual SR
if size(imlowy,1)*size(imlowy,2) > managableMax
    impred = runPatchVDSR(net, imlowy, gpu, 20);
else
    if gpu,
        imlowy = gpuArray(imlowy);
    end
    impred = runVDSR(net, imlowy, gpu);
end

if size(lIm,3) > 1
    impredColor = cat(3,impred,imlowcb,imlowcr);
else
    impredColor = impred;
end

sr_img = im2double(impredColor); % Going back to double images

cd(currentDir);

