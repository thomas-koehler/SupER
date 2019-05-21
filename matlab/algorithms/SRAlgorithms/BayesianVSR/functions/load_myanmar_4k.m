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

function [vidHi_orig, vidLo] = load_myanmar_4k(srParam,upScale,part)

    vidHi_orig = [];
    vidLo = [];
    testVideo = srParam.testVideo;
    imgPath = testVideo.imgPath;
    nFrame = testVideo.nFrame;
    scene = testVideo.scene;
    offset = 200;
    
    height = 2160;
    width = 3840;

    load('/home/andrew/HDData/2_sr4k/codes/data/index_myanmar/MyanmarIndex.mat');
    frame1 = MyanmarIndex(scene,1) + offset;
    
    %get Filesize and Framenumber
    h = waitbar(0,'Please wait ... ');
    %read YUV-Frames
    for cntf = frame1 : frame1+nFrame-1
        index = cntf - frame1 + 1;
        waitbar(index/nFrame,h); %(cntf/framenumber,h);
        file = [imgPath sprintf('/Myanmar_Full_UHD_60P_Branded_%05d',cntf) '.dpx'];
        RGB = uint8(readdpx1(file)/4);
        %RGB = readdpx1(file);
        switch (part) 
            case 0 % 3840x2160
                vidHi_orig{index} = im2double(RGB);
            case 1 % 960x540  (1/4)
                vidHi_orig{index} = im2double(RGB(height*3/8+1:height*5/8,width*3/8+1:width*5/8,:));
            case 2 % 960x540 (1/4)
                vidHi_orig{index} = im2double(RGB((3*height/4+1):end,1:width/4,:));
            case 3 % 960x540 (1/4)
                vidHi_orig{index} = im2double(RGB((3*height/4+1):end,(width/4+1):width/2,:));
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

%             if srParam.norm == 0
%                 vidLo{index} = vidLo{index} .* 255;
%                 vidHi_orig{index} = vidHi_orig{index} .* 255;
%             end

        if 0%index == 1
            figure, imshow(vidHi_orig{index});
            figure, imshow(vidLo{index});
        end
    end
    close(h);

end