function sr_img = superresolve_vsrnet(slidingWindows, magFactor)
%
% MAGI-ADAPTED EVALUATION SCRIPT
%
% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
% *************************************************************************

numberOfFrames = size(slidingWindows.frames,3);
lr_frames      = slidingWindows.frames(:,:,((numberOfFrames+1)/2)-2:((numberOfFrames+1)/2)+2);
upscaling      = magFactor;

%clearvars

% GENERAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CAFFEPATH = '/HOMES/baetz/develop/CAFFE/caffe/';   % path to caffe installation

% MAGI-ADAPT: MATLAB crashes with 1
LOW_MEMORY_MODE = 3;    % if Matlab crashes, try a higher number:
                        % 0 = high GPU memory usage -> fastest
                        % 1 = medium GPU memory usage -> fast
                        % 2 = low GPU memory usage -> slow
                        % 3 = similar to 1 but more tiles (MAGI-EXTENSION)
                        
USE_GPU = false;         % set to false, if no GPU available -> slowest
GPU_ID = 0;             % GPU ID -> should normally be 0   

% RUN VSRnet on Video %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TESTVIDEO_PATH = lr_video_path; %'data/lr_video/u2/foreman_LR.mat'; % path to input video frames
% a variable "frames" with dimensions (width x height x nrFrames) is expected
UPSCALE_FACTOR = upscaling; %2;                 % upscale factor: 2,3,4 are available

MOTIONCOMPENSATION = true;          % use Motion Compensation (much faster)
% Note: MOTIONCOMPENSATION=false is only available for upscale factor 3
ADAPTIVEMOTIONCOMPENSATION = false; % use Adaptive Motion Compensation
TESTONLY1FRAME = 0;                 % 0: all frames will be tested, otherwise only one frame will be tested
%RESULTFILE_PATH = sr_video_path; %['results/magi_quick_test'];% filename for results
PREPROCESSED_INPUT = false;         % do not change

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% start processing
%addpath('functions','external_functions/CLG-TV-matlab',[CAFFEPATH '/matlab'])
% MAGI-ADAPT
addpath('/HOMES/baetz/develop/VSRnet/functions')
addpath('/HOMES/baetz/develop/VSRnet/external_functions/CLG-TV-matlab')
addpath([CAFFEPATH '/matlab'])
%run('main_VSRnet_test.m') % MAGI-INPUT: main_VSRnet_test.m follows

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
    model_def_file_template = ['/HOMES/baetz/develop/VSRnet/models/u' num2str(UPSCALE_FACTOR) '/superres_deploy.prototxt'];
    model_file =    ['/HOMES/baetz/develop/VSRnet/models/u' num2str(UPSCALE_FACTOR) '/SRnet_train_iter_200000.caffemodel'];  
else
    model_def_file_template = ['/HOMES/baetz/develop/VSRnet/models/u' num2str(UPSCALE_FACTOR) '_noMotionCompensation/superres_deploy.prototxt'];
    model_file =    ['/HOMES/baetz/develop/VSRnet/models/u' num2str(UPSCALE_FACTOR) '_noMotionCompensation/SRnet_train_iter_200000.caffemodel'];      
end
model_def_file = '/HOMES/baetz/develop/VSRnet/models/tmp/tmp_superres_deploy.prototxt';

%% preprocess input data

%TESTVIDEO_PATH
if PREPROCESSED_INPUT
    %load(TESTVIDEO_PATH);

    if TESTONLY1FRAME       
        input_data{1} = input_data{1}(:,:,:,TESTONLY1FRAME);
        im_gt = im_gt(:,:,:,TESTONLY1FRAME);
    end
else
    %data = load(TESTVIDEO_PATH);
    % MAGI-ADD: padding to avoid errors near the border
    for itera = 1:size(lr_frames,3),
        tmp_padded = padarray(lr_frames(:,:,itera).',BORDERSIZE,'symmetric','both');
        lr_frames_padded(:,:,itera) = padarray(tmp_padded.',BORDERSIZE,'symmetric','both');
    end
    
    data.frames = lr_frames_padded;
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
elseif LOW_MEMORY_MODE==3, % MAGI-EXTENSION
    BORDERSIZE = BORDERSIZE * 2;
    imagecutX1 = imageSize(1)/4;
    imagecutX2 = imageSize(1)/4 * 2;
    imagecutX3 = imageSize(1)/4 * 3;
    imagecutY1 = imageSize(2)/4;
    imagecutY2 = imageSize(2)/4 * 2;
    imagecutY3 = imageSize(2)/4 * 3;
    
    imageSize(1) = imageSize(1)/4 + BORDERSIZE;
    imageSize(2) = imageSize(2)/4 + BORDERSIZE;
end

change_caffe_image_input_size(model_def_file_template,model_def_file,imageSize,1)
net = caffe.Net(model_def_file, model_file, 'test');

%% do forward pass

%tic;  
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
    % MAGI-EXTENSION
    elseif LOW_MEMORY_MODE==3, % divide image in four parts to reduce memory usage
        tmp1 = net.forward({input_data{1}(1:imagecutY1 + BORDERSIZE,1:imagecutX1 + BORDERSIZE,:,imgIdx)});
        tmp2 = net.forward({input_data{1}(1:imagecutY1 + BORDERSIZE,imagecutX1+1-BORDERSIZE/2:imagecutX2+BORDERSIZE/2,:,imgIdx)});
        tmp3 = net.forward({input_data{1}(1:imagecutY1 + BORDERSIZE,imagecutX2+1-BORDERSIZE/2:imagecutX3+BORDERSIZE/2,:,imgIdx)});
        tmp4 = net.forward({input_data{1}(1:imagecutY1 + BORDERSIZE,imagecutX3+1-BORDERSIZE:end,:,imgIdx)});
        
        tmp5 = net.forward({input_data{1}(imagecutY1+1-BORDERSIZE/2:imagecutY2+BORDERSIZE/2,1:imagecutX1 + BORDERSIZE,:,imgIdx)});
        tmp6 = net.forward({input_data{1}(imagecutY1+1-BORDERSIZE/2:imagecutY2+BORDERSIZE/2,imagecutX1+1-BORDERSIZE/2:imagecutX2+BORDERSIZE/2,:,imgIdx)});
        tmp7 = net.forward({input_data{1}(imagecutY1+1-BORDERSIZE/2:imagecutY2+BORDERSIZE/2,imagecutX2+1-BORDERSIZE/2:imagecutX3+BORDERSIZE/2,:,imgIdx)});
        tmp8 = net.forward({input_data{1}(imagecutY1+1-BORDERSIZE/2:imagecutY2+BORDERSIZE/2,imagecutX3+1-BORDERSIZE:end,:,imgIdx)});
        
        tmp9 = net.forward({input_data{1}(imagecutY2+1-BORDERSIZE/2:imagecutY3+BORDERSIZE/2,1:imagecutX1 + BORDERSIZE,:,imgIdx)});
        tmp10 = net.forward({input_data{1}(imagecutY2+1-BORDERSIZE/2:imagecutY3+BORDERSIZE/2,imagecutX1+1-BORDERSIZE/2:imagecutX2+BORDERSIZE/2,:,imgIdx)});
        tmp11 = net.forward({input_data{1}(imagecutY2+1-BORDERSIZE/2:imagecutY3+BORDERSIZE/2,imagecutX2+1-BORDERSIZE/2:imagecutX3+BORDERSIZE/2,:,imgIdx)});
        tmp12 = net.forward({input_data{1}(imagecutY2+1-BORDERSIZE/2:imagecutY3+BORDERSIZE/2,imagecutX3+1-BORDERSIZE:end,:,imgIdx)});
        
        tmp13 = net.forward({input_data{1}(imagecutY3+1-BORDERSIZE:end,1:imagecutX1 + BORDERSIZE,:,imgIdx)});
        tmp14 = net.forward({input_data{1}(imagecutY3+1-BORDERSIZE:end,imagecutX1+1-BORDERSIZE/2:imagecutX2+BORDERSIZE/2,:,imgIdx)});
        tmp15 = net.forward({input_data{1}(imagecutY3+1-BORDERSIZE:end,imagecutX2+1-BORDERSIZE/2:imagecutX3+BORDERSIZE/2,:,imgIdx)});
        tmp16 = net.forward({input_data{1}(imagecutY3+1-BORDERSIZE:end,imagecutX3+1-BORDERSIZE:end,:,imgIdx)});
         
        out_tmp1 = cat(2,tmp1{1}(:,1:imagecutX1,:,:),tmp2{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp3{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp4{1}(:,BORDERSIZE+1:end,:,:));
        out_tmp2 = cat(2,tmp5{1}(:,1:imagecutX1,:,:),tmp6{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp7{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp8{1}(:,BORDERSIZE+1:end,:,:));
        out_tmp3 = cat(2,tmp9{1}(:,1:imagecutX1,:,:),tmp10{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp11{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp12{1}(:,BORDERSIZE+1:end,:,:));
        out_tmp4 = cat(2,tmp13{1}(:,1:imagecutX1,:,:),tmp14{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp15{1}(:,BORDERSIZE/2+1:end-BORDERSIZE/2,:,:),tmp16{1}(:,BORDERSIZE+1:end,:,:));
        
        output(:,:,:,imgIdx) = cat(1,out_tmp1(1:imagecutY1,:,:,:),out_tmp2(BORDERSIZE/2+1:end-BORDERSIZE/2,:,:,:),out_tmp3(BORDERSIZE/2+1:end-BORDERSIZE/2,:,:,:),out_tmp4(BORDERSIZE+1:end,:,:,:));
    else
        tmp = net.forward({input_data{1}(:,:,:,imgIdx)});
        output(:,:,:,imgIdx) = tmp{1};
    end
end
%toc;

im_SR = output;
im_SR = permute(im_SR,[2 1 3 4]);
im_SR = im_SR*255;  

% MAGI-ADD: cropping the previously introduced padding
im_SR = im_SR(1+BORDERSIZE/2*UPSCALE_FACTOR:end-BORDERSIZE/2*UPSCALE_FACTOR,1+BORDERSIZE/2*UPSCALE_FACTOR:end-BORDERSIZE/2*UPSCALE_FACTOR);
im_SR(im_SR > 255) = 255;
im_SR(im_SR < 0) = 0;

%save(RESULTFILE_PATH,'im_SR','model_file','TESTVIDEO_PATH'); % MAGI-COMMENTED
sr_img = im_SR;

%run('evaluate_result.m')

