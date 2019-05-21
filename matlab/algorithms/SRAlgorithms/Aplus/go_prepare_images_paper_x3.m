%load('Set5_x4_1024atoms_conf_Zeyde_1024_finalx4_results_imgscale_1.mat')
load('Set5_x3_1024atoms_conf_Zeyde_1024_finalx3_results_imgscale_1.mat')
%%
selection = [1 2 3 4 5 6 7 8 9];
name = 'baby_GT';

for s = selection
     I = imread([conf.result_dirRGB '/' name '[' num2str(s) '-' conf.desc{s} '].bmp']);
     I = go_prepare_image(I, 115,165,80,60,4, 40,85);
     figure; imshow(I); title(conf.desc{s});
     if s == 3
        imwrite(I, [name '[' num2str(s) '-Yang]_x3.png']);
     elseif s==4
         imwrite(I, [name '[' num2str(s) '-Zeyde]_x3.png']);
     elseif s==5
         imwrite(I, [name '[' num2str(s) '-GR]_x3.png']);
     elseif s==6
         imwrite(I, [name '[' num2str(s) '-ANR]_x3.png']);
     else
        imwrite(I, [name '[' num2str(s) '-' conf.desc{s} ']_x3.png']);
     end
end
%%
selection = [1 2 3 4 5 6 7 8 9];
name = 'bird_GT';
for s = selection
     I = imread([conf.result_dirRGB '/' name '[' num2str(s) '-' conf.desc{s} '].bmp']);
     I = go_prepare_image(I, 135,35,40,40,4, 30,55);
     figure; imshow(I); title(conf.desc{s});
     if s == 3
        imwrite(I, [name '[' num2str(s) '-Yang]_x3.png']);
     elseif s==4
         imwrite(I, [name '[' num2str(s) '-Zeyde]_x3.png']);
     elseif s==5
         imwrite(I, [name '[' num2str(s) '-GR]_x3.png']);
     elseif s==6
         imwrite(I, [name '[' num2str(s) '-ANR]_x3.png']);
     else
        imwrite(I, [name '[' num2str(s) '-' conf.desc{s} ']_x3.png']);
     end
end
%%
selection = [1 2 3 4 5 6 7 8 9];
name = 'butterfly_GT';
for s = selection
     I = imread([conf.result_dirRGB '/' name '[' num2str(s) '-' conf.desc{s} '].bmp']);
     %I = go_prepare_image(I, 135,65,40,40,4, 30,55);
     I = go_prepare_image(I, 135,85,40,40,4, 30,55);
     figure; imshow(I); title(conf.desc{s});
     if s == 3
        imwrite(I, [name '[' num2str(s) '-Yang]_x3.png']);
     elseif s==4
         imwrite(I, [name '[' num2str(s) '-Zeyde]_x3.png']);
     elseif s==5
         imwrite(I, [name '[' num2str(s) '-GR]_x3.png']);
     elseif s==6
         imwrite(I, [name '[' num2str(s) '-ANR]_x3.png']);
     else
        imwrite(I, [name '[' num2str(s) '-' conf.desc{s} ']_x3.png']);
     end
end