function DRCN(datasetName, SF, model, outRoute)

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

dataDir = fullfile('data', datasetName);
f_lst = dir(fullfile(dataDir, '*.*'));
evaltable = zeros(numel(f_lst),2);
for f_iter = 1:numel(f_lst)
    f_info = f_lst(f_iter);
    if f_info.isdir, continue; end
    [~,imgName,~] = fileparts(f_lst(f_iter).name);
    imGT = imread(fullfile(dataDir, f_info.name));
    if size(imGT,3) > 1    
        im = rgb2ycbcr(imGT);
    else
        im = imGT;
    end
    imhigh = modcrop(im, SF);
    imhigh = single(imhigh)/255;
    imlow = imresize(imhigh, 1/SF, 'bicubic');
    imlow = imresize(imlow, SF, 'bicubic');
    if size(imlow,3)>1
        imlowy = imlow(:,:,1);
        imlowy = max(16.0/255, min(235.0/255, imlowy));
        imlowcb = imlow(:,:,2);
        imlowcr = imlow(:,:,3);
    else
        imlowy = imlow;
    end

    if size(imlowy,1)*size(imlowy,2) > managableMax
        impred = runPatchDRCN(net, imlowy, gpu, 20);
    else
        if gpu, imlowy = gpuArray(imlowy); end;
        impred = runDRCN(net, imlowy, gpu);
    end
    
    if size(imGT,3) > 1
        impredColor = cat(3,impred,imlowcb,imlowcr);
        imwrite(ycbcr2rgb(uint8(impredColor*255)), fullfile(outRoute, [imgName, '.png']));
    else
        impredColor = impred;
        imwrite(uint8(impredColor*255), fullfile(outRoute, [imgName, '.png']));
    end
    imtest = imread(fullfile(outRoute, [imgName, '.png']));
    [psnr, ssim] = compute_diff(imGT,imtest,SF);
    evaltable(f_iter,1) = psnr; evaltable(f_iter,2) = ssim;    
end

save(fullfile(outRoute,'psnr_ssim.mat'),'evaltable');