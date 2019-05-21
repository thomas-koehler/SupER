%yuv2mov creates a Matlab-Movie from a YUV-File.
%	yuv2mov('Filename', width, height, format) reads the specified file
%	using width and height for resolution and format for YUV-subsampling.
%	
%	Filename --> Name of File (e.g. 'Test.yuv')
%   width    --> width of a frame  (e.g. 352)
%   height   --> height of a frame (e.g. 280)
%   format   --> subsampling rate ('400','411','420','422' or '444')
%
%example: mov = yuv2mov('Test.yuv',352,288,'420');

function [vidHi_orig, vidLo] = load_yuv_4k(testVideo,width,height,upScale,part,param)

    vidHi_orig = [];
    vidLo = [];
    File = testVideo.file;
    format = testVideo.format;
    nFrame = length(testVideo.range);
    range = testVideo.range;
    
    %set factor for UV-sampling
    fwidth = 0.5;
    fheight= 0.5;
    if strcmp(format,'400')
        fwidth = 0;
        fheight= 0;
    elseif strcmp(format,'411')
        fwidth = 0.25;
        fheight= 1;
    elseif strcmp(format,'420')
        fwidth = 0.5;
        fheight= 0.5;
    elseif strcmp(format,'422')
        fwidth = 0.5;
        fheight= 1;
    elseif strcmp(format,'444')
        fwidth = 1;
        fheight= 1;
    else
        display('Error: wrong format');
    end
    %get Filesize and Framenumber
    filep = dir(File); 
    fileBytes = filep.bytes; %Filesize
    clear filep
    framenumber = fileBytes/(width*height*(1+2*fheight*fwidth)); %Framenumber
%     if mod(framenumber,1) ~= 0
    if 0
        display('Error: wrong resolution, format or filesize');
    else
        h = waitbar(0,'Please wait ... ');
        %read YUV-Frames
        for cntf = range %1:1:nFrame %framenumber
            index = cntf-range(1)+1;
            waitbar(index/nFrame,h); %(cntf/framenumber,h);
            YUV = loadFileYUV(width,height,cntf,File,fheight,fwidth);
            RGB = ycbcr2rgb(YUV); %Convert YUV to RGB
            switch (part) 
                case 0 % 3840x2160
                    vidHi_orig{index} = im2double(RGB);
                case 1 % 960x540  (1/4)
                    vidHi_orig{index} = im2double(RGB(height*3/8+1:height*5/8,width*3/8+1:width*5/8,:));
                case 2 % 960x540 (1/4)
                    vidHi_orig{index} = im2double(RGB((3*height/4+1):end,1:width/4,:));
                case 3 % 1920x1080  (1/2)
                    vidHi_orig{index} = im2double(RGB((height/2+1):end,1:width/2,:));
                case 4 % 240x136 (almost 1/16)
                    vidHi_orig{index} = im2double(RGB((15*height/16):end,1:width/16,:));
                case 5 % 120x64 (almost 1/32)
                    vidHi_orig{index} = im2double(RGB(2000:2063,(11:width/32+10),:));
                case 6 % 480x270
                    vidHi_orig{index} = im2double(RGB(height/2-99:height*5/8-100,width/2-399:width*5/8-400,:));
                case 7 % 480x270
                    vidHi_orig{index} = im2double(RGB(height/2-99:height*5/8-100,width/4+21:width*3/8+20,:));
                case 8 % 480x270 (corner)
                    vidHi_orig{index} = im2double(RGB(1:height/8,1:width/8,:));
                    
            end
            vidLo{index} = imresize(vidHi_orig{index},1.0/upScale,'bicubic'); % 1/DParam.upscaleFactor
            if index == 1
                if param.SHOW_IMAGE
                    figure, imshow(vidHi_orig{index});
                    figure, imshow(vidLo{index});
                end
            end
        end
        close(h);
    end



% loadFileYUV(width,height,Frame_Number,File,fheight,fwidth)
function YUV = loadFileYUV(width,heigth,Frame,fileName,Teil_h,Teil_b)
    % get size of U and V
    fileId = fopen(fileName,'r');
    width_h = width*Teil_b;
    heigth_h = heigth*Teil_h;
    % compute factor for framesize
    factor = 1+(Teil_h*Teil_b)*2;
    % compute framesize
    framesize = width*heigth;
      
    fseek(fileId,(Frame-1)*factor*framesize, 'bof');
    % create Y-Matrix
    YMatrix = fread(fileId, width * heigth, 'uchar');
    YMatrix = int16(reshape(YMatrix,width,heigth)');
    % create U- and V- Matrix
    if Teil_h == 0
        UMatrix = 0;
        VMatrix = 0;
    else
        UMatrix = fread(fileId,width_h * heigth_h, 'uchar');
        UMatrix = int16(UMatrix);
        UMatrix = reshape(UMatrix,width_h, heigth_h).';
        
        VMatrix = fread(fileId,width_h * heigth_h, 'uchar');
        VMatrix = int16(VMatrix);
        VMatrix = reshape(VMatrix,width_h, heigth_h).';       
    end
    % compose the YUV-matrix:
    YUV(1:heigth,1:width,1) = YMatrix;
    
    if Teil_h == 0
        YUV(:,:,2) = 127;
        YUV(:,:,3) = 127;
    end
    % consideration of the subsampling of U and V
    if Teil_b == 1
        UMatrix1(:,:) = UMatrix(:,:);
        VMatrix1(:,:) = VMatrix(:,:);
    
    elseif Teil_b == 0.5        
        UMatrix1(1:heigth_h,1:width) = int16(0);
        UMatrix1(1:heigth_h,1:2:end) = UMatrix(:,1:1:end);
        UMatrix1(1:heigth_h,2:2:end) = UMatrix(:,1:1:end);
 
        VMatrix1(1:heigth_h,1:width) = int16(0);
        VMatrix1(1:heigth_h,1:2:end) = VMatrix(:,1:1:end);
        VMatrix1(1:heigth_h,2:2:end) = VMatrix(:,1:1:end);
    
    elseif Teil_b == 0.25
        UMatrix1(1:heigth_h,1:width) = int16(0);
        UMatrix1(1:heigth_h,1:4:end) = UMatrix(:,1:1:end);
        UMatrix1(1:heigth_h,2:4:end) = UMatrix(:,1:1:end);
        UMatrix1(1:heigth_h,3:4:end) = UMatrix(:,1:1:end);
        UMatrix1(1:heigth_h,4:4:end) = UMatrix(:,1:1:end);
        
        VMatrix1(1:heigth_h,1:width) = int16(0);
        VMatrix1(1:heigth_h,1:4:end) = VMatrix(:,1:1:end);
        VMatrix1(1:heigth_h,2:4:end) = VMatrix(:,1:1:end);
        VMatrix1(1:heigth_h,3:4:end) = VMatrix(:,1:1:end);
        VMatrix1(1:heigth_h,4:4:end) = VMatrix(:,1:1:end);
    end
    
    if Teil_h == 1
        YUV(:,:,2) = UMatrix1(:,:);
        YUV(:,:,3) = VMatrix1(:,:);
        
    elseif Teil_h == 0.5        
        YUV(1:heigth,1:width,2) = int16(0);
        YUV(1:2:end,:,2) = UMatrix1(:,:);
        YUV(2:2:end,:,2) = UMatrix1(:,:);
        
        YUV(1:heigth,1:width,3) = int16(0);
        YUV(1:2:end,:,3) = VMatrix1(:,:);
        YUV(2:2:end,:,3) = VMatrix1(:,:);
        
    elseif Teil_h == 0.25
        YUV(1:heigth,1:width,2) = int16(0);
        YUV(1:4:end,:,2) = UMatrix1(:,:);
        YUV(2:4:end,:,2) = UMatrix1(:,:);
        YUV(3:4:end,:,2) = UMatrix1(:,:);
        YUV(4:4:end,:,2) = UMatrix1(:,:);
        
        YUV(1:heigth,1:width) = int16(0);
        YUV(1:4:end,:,3) = VMatrix1(:,:);
        YUV(2:4:end,:,3) = VMatrix1(:,:);
        YUV(3:4:end,:,3) = VMatrix1(:,:);
        YUV(4:4:end,:,3) = VMatrix1(:,:);
    end
    YUV = uint8(YUV);
    fclose(fileId);