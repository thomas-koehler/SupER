% construct the desired regularization matrix 
%
%

function Sigma = construct_reg_mat(n, type)

switch lower(type)
    case 'elastic'
        Sigma = eye(n);
    case 'tikhonov',
        Sigma = eye(n);
        for ii = 1:size(Sigma, 1)-1,
            Sigma(ii, ii+1) = -1;
        end
        Sigma(end, 1) = -1;
        Sigma = Sigma'*Sigma;
    otherwise
        error('no such type!');
end