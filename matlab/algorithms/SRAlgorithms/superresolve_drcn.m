function sr_img = superresolve_drcn(slidingWindows, magFactor)

lIm       = slidingWindows.referenceFrame;
upscaling = magFactor;


% Important Note: Grayscale or YCbCr input data expected!

currentDir = pwd;
cd('../algorithms/SRAlgorithms/DRCN'); % MAGI-FIX

run('snu_matconvnet/matlab/vl_setupnn.m');

model = ['sf',num2str(upscaling),'/DRCN_sf',num2str(upscaling),'.mat'];

if isempty(model)
    error('no model');
else
    modelPath = ['DRCN model/',model];
    %gpu = 1;
    gpu = 0; % MAGI-ADAPT
end

load(modelPath);

net = dagnn.DagNN.loadobj(net);

if gpu
    net.move('gpu');
end

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
    impred = runPatchDRCN(net, imlowy, gpu, 20);
else
    if gpu,
        imlowy = gpuArray(imlowy);
    end
    impred = runDRCN(net, imlowy, gpu);
end

if size(lIm,3) > 1
    impredColor = cat(3,impred,imlowcb,imlowcr);
else
    impredColor = impred;
end

sr_img = im2double(impredColor); % Going back to double images

cd(currentDir);

