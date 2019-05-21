% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
% 
% main VSRnet script, includes the interface to the caffe framework 
% do not run this script directly. call it from VSRnet_demo instead
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% *************************************************************************

%% more parameters (do not change, unless you know what you are doing)

BORDERSIZE = 8; %4+2+2; %border size = sum of all zeropaddings in model def file

% parameters for LOW_MEMORY_MODE=2
Param.patchSize = 36;
Param.stride = 20; 
Param.outputPatchSize = 20;
Param.zeropadding = 1;

%% Init VSRnet configuration files

if (MOTIONCOMPENSATION==false && UPSCALE_FACTOR ~= 3 && ADAPTIVEMOTIONCOMPENSATION==false)
    error('Error: MOTIONCOMPENSATION=false is only available for upscale factor 3. Please either set UPSCALEFACTOR=3 or MOTIONCOMPENSATION=true')
end
if (MOTIONCOMPENSATION==false && ADAPTIVEMOTIONCOMPENSATION==true)
    display('The MOTIONCOMPENSATION flag is ignored because ADAPTIVEMOTIONCOMPENSATION=true')
end

if MOTIONCOMPENSATION 
    model_def_file_template = ['models/u' num2str(UPSCALE_FACTOR) '/superres_deploy.prototxt'];
    model_file =    ['models/u' num2str(UPSCALE_FACTOR) '/SRnet_train_iter_200000.caffemodel'];  
else
    model_def_file_template = ['models/u' num2str(UPSCALE_FACTOR) '_noMotionCompensation/superres_deploy.prototxt'];
    model_file =    ['models/u' num2str(UPSCALE_FACTOR) '_noMotionCompensation/SRnet_train_iter_200000.caffemodel'];      
end
model_def_file = 'models/tmp/tmp_superres_deploy.prototxt';

%% preprocess input data

TESTVIDEO_PATH
if PREPROCESSED_INPUT
    load(TESTVIDEO_PATH);

    if TESTONLY1FRAME       
        input_data{1} = input_data{1}(:,:,:,TESTONLY1FRAME);
        im_gt = im_gt(:,:,:,TESTONLY1FRAME);
    end
else
    data = load(TESTVIDEO_PATH);
    if TESTONLY1FRAME 
        data.frames = data.frames(:,:,TESTONLY1FRAME:TESTONLY1FRAME+4);
    end
    [input_data,idx_gt] = preprocess_frames(data.frames,UPSCALE_FACTOR,MOTIONCOMPENSATION,ADAPTIVEMOTIONCOMPENSATION);

end
im_bic = permute(input_data{1}(:,:,3,:),[2,1,3,4])*255;

%% caffe setup
        
batchsize = size(input_data{1},4);
imageSize = [ size(input_data{1},2), size(input_data{1},1)];
Param.inputImgSize = imageSize;

caffe.reset_all();

if USE_GPU
  caffe.set_mode_gpu();
  caffe.set_device(GPU_ID);
else
  caffe.set_mode_cpu();
end

if LOW_MEMORY_MODE==1
    imagecut = imageSize(1)/2;
    imageSize(1) = imageSize(1)/2 + BORDERSIZE;
elseif LOW_MEMORY_MODE==2
    imageSize = [Param.patchSize Param.patchSize];                             
end

change_caffe_image_input_size(model_def_file_template,model_def_file,imageSize,1)
net = caffe.Net(model_def_file, model_file, 'test');

%% do forward pass

tic;  
output = zeros(size(im_bic,2),size(im_bic,1),size(im_bic,3),size(im_bic,4));
for imgIdx = 1:size(im_bic,4)
    display(['Superresolve frame ' num2str(imgIdx)]);
    if LOW_MEMORY_MODE==1 % divide image in two parts to reduce memory usage
        tmp1 = net.forward({input_data{1}(:,1:imagecut + BORDERSIZE,:,imgIdx)});
        tmp2 = net.forward({input_data{1}(:,imagecut+1-BORDERSIZE:end,:,imgIdx)}); 
        output(:,:,:,imgIdx) = cat(2,tmp1{1}(:,1:imagecut,:,:),tmp2{1}(:,BORDERSIZE+1:end,:,:));
    elseif LOW_MEMORY_MODE==2 % process the image patchwise
        input_data_new = patchify(input_data{1}(:,:,:,imgIdx), Param);
        if Param.zeropadding==1
            output_raw = zeros(size(input_data_new,1),size(input_data_new,2),1,size(input_data_new,4));
        else
            output_raw = zeros(Param.outputPatchSize,Param.outputPatchSize,1,size(input_data_new,4));
        end
        for pIdx = 1:size(input_data_new,4)
            output_raw_tmp = net.forward({input_data_new(:,:,:,pIdx)});  
            output_raw(:,:,:,pIdx) = output_raw_tmp{1};
            if mod(pIdx,1000)==0
                fprintf('.');
            end
        end   
        fprintf('\n');
        output(:,:,:,imgIdx) = depatchify(output_raw,Param);
    else
        tmp = net.forward({input_data{1}(:,:,:,imgIdx)});
        output(:,:,:,imgIdx) = tmp{1};
    end
end
toc;

im_SR = output;
im_SR = permute(im_SR,[2 1 3 4]);
im_SR = im_SR*255;  

save(RESULTFILE_PATH,'im_SR','model_file','TESTVIDEO_PATH');
