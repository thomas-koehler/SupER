function [Dh, Dl] = coupled_dic_train(Xh, Xl, codebook_size, lambda)

d = pwd;
addpath([d '/../CVPR08-SR/Sparse_coding/sc2']);

hDim = size(Xh, 1);
lDim = size(Xl, 1);

% joint learning of the dictionary
X = [1/sqrt(hDim)*Xh; 1/sqrt(lDim)*Xl];
X = X(:, 1:80000);
Xnorm = sqrt(sum(X.^2, 1));

clear Xh Xl;

X = X(:, Xnorm > 1e-5);
X = X./repmat(sqrt(sum(X.^2, 1)), hDim+lDim, 1);

idx = randperm(size(X, 2));
Binit = X(:, idx(1:codebook_size));

[D] = sparse_coding(X, codebook_size, lambda/2, 'L1', [], 50, 5000, [], [], Binit);

Dh = D(1:hDim, :);
Dl = D(hDim+1:end, :);

% normalize the dictionary
Dh = Dh./repmat(sqrt(sum(Dh.^2, 1)), hDim, 1);
Dl = Dl./repmat(sqrt(sum(Dl.^2, 1)), lDim, 1);





