function [imgs imgsCB imgsCR] = load_images(paths)

imgs = cell(size(paths));
imgsCB = cell(size(paths));
imgsCR = cell(size(paths));
for i = 1:numel(paths)
    X = imread(paths{i});
    if size(X, 3) == 3 % we extract our features from Y channel
        X = rgb2ycbcr(X);        
        %X = rgb2gray(X);                
        imgsCB{i} = im2single(X(:,:,2)); 
        imgsCR{i} = im2single(X(:,:,3));
        X = X(:, :, 1);
    end
    X = im2single(X); % to reduce memory usage
    imgs{i} = X;
end
