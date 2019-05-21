function [Dh, Dl] = train_coupled_dict(Xh, Xl, dict_size, lambda, upscale)

addpath(genpath('RegularizedSC'));

hDim = size(Xh, 1);
lDim = size(Xl, 1);

% should pre-normalize Xh and Xl !
hNorm = sqrt(sum(Xh.^2));
lNorm = sqrt(sum(Xl.^2));
Idx = find( hNorm & lNorm );

Xh = Xh(:, Idx);
Xl = Xl(:, Idx);

Xh = Xh./repmat(sqrt(sum(Xh.^2)), size(Xh, 1), 1);
Xl = Xl./repmat(sqrt(sum(Xl.^2)), size(Xl, 1), 1);

% joint learning of the dictionary
X = [sqrt(hDim)*Xh; sqrt(lDim)*Xl];
Xnorm = sqrt(sum(X.^2, 1));

clear Xh Xl;

X = X(:, Xnorm > 1e-5);
X = X./repmat(sqrt(sum(X.^2, 1)), hDim+lDim, 1);

idx = randperm(size(X, 2));

% dictionary training
[D] = reg_sparse_coding(X, dict_size, [], 0, lambda, 40);

Dh = D(1:hDim, :);
Dl = D(hDim+1:end, :);

% normalize the dictionary
% Dh = Dh./repmat(sqrt(sum(Dh.^2, 1)), hDim, 1);
% Dl = Dl./repmat(sqrt(sum(Dl.^2, 1)), lDim, 1);

patch_size = sqrt(size(Dh, 1));

%dict_path = ['Dictionary/D_' num2str(dict_size) '_' num2str(lambda) '_' num2str(patch_size) '_s' num2str(upscale) '.mat' ];
dict_path = ['Dictionary/MagiD_' num2str(dict_size) '_' num2str(lambda) '_' num2str(patch_size) '_s' num2str(upscale) '.mat' ]; % MAGI-STUFF
save(dict_path, 'Dh', 'Dl');