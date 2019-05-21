function change_caffe_image_input_size(inFile,outFile,size,batchsize)
% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
%
% Changes the frame size in the caffe prototxt file  
%
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% *************************************************************************

    txt = fileread(inFile);
    A = regexp(txt,'@DIM_B@','split');
    B = regexp(A{2},'@DIM_X@','split');
    C = regexp(B{2},'@DIM_Y@','split');
    
    A{2} = num2str(batchsize);
    A{3} = B{1};
    A{4} = num2str(size(1));
    A{5} = C{1};
    A{6} = num2str(size(2));
    A{7} = C{2};

    fid = fopen(outFile,'w');
    fprintf(fid,'%s',A{:});
    fclose(fid);
end