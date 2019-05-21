function [sols, numIters, activationHist, duals] = SolveLasso(A, y, N, algType, maxIters, lambdaStop, resStop, solFreq, verbose, OptTol)
% SolveLasso: Implements the Lars/Lasso algorithms
% Usage
%	[sols, numIters, activationHist, duals] = SolveLasso(A, y, N, algType,
%	maxIters, lambdaStop, resStop, solFreq, verbose, OptTol)
% Input
%	A           Either an explicit nxN matrix, with rank(A) = min(N,n) 
%               by assumption, or a string containing the name of a 
%               function implementing an implicit matrix (see below for 
%               details on the format of the function).
%	y           vector of length n.
%   N           length of solution vector. 
%   algType     'lars' for the Lars algorithm, 
%               'lasso' for lars with the lasso modification (default).
%               Add prefix 'nn' (i.e. 'nnlars' or 'nnlasso') to add a
%               non-negativity constraint (omitted by default)
%	maxIters    maximum number of Lars iterations to perform. If not
%               specified, runs to stopping condition (default)
%   lambdaStop  If specified (and > 0), the algorithm terminates when the
%               Lagrange multiplier <= lambdaStop. 
%   resStop     If specified (and > 0), the algorithm terminates when the
%               L2 norm of the residual <= resStop. 
%   solFreq     if =0 returns only the final solution, if >0, returns an 
%               array of solutions, one every solFreq iterations (default 0). 
%   verbose     1 to print out detailed progress at each iteration, 0 for
%               no output (default)
%	OptTol      Error tolerance, default 1e-5
% Outputs
%	sols           solution(s) of the Lasso/Lars problem
%	numIters       Total number of steps taken
%   activationHist Array of indices showing elements entering and 
%                  leaving the solution set
%	duals          solution(s) of the the dual Lasso problem
% Description
%   SolveLasso implements the Lars algorithm, as described by Efron et al. in 
%   "Least Angle Regression". Currently, the original algorithm is
%   implemented, as well as the lasso modification, which solves 
%      min lambda*||x||_1 + 1/2|| y - Ax ||_2^2
%   for all lambda >= 0, using a path following method with parameter lambda.
%   Optionally, if a non-negativity constraint is imposed, the algorithm 
%   instead solves
%      min lambda*1'*x + 1/2|| y - Ax ||_2^2 s.t. x >= 0
%   The implementation implicitly factors the active set matrix A(:,I)
%   using Choleskly updates. 
%   The matrix A can be either an explicit matrix, or an implicit operator
%   implemented as an m-file. If using the implicit form, the user should
%   provide the name of a function of the following format:
%     y = OperatorName(mode, m, n, x, I, dim)
%   This function gets as input a vector x and an index set I, and returns
%   y = A(:,I)*x if mode = 1, or y = A(:,I)'*x if mode = 2. 
%   A is the m by dim implicit matrix implemented by the function. I is a
%   subset of the columns of A, i.e. a subset of 1:dim of length n. x is a
%   vector of length n if mode = 1, or a vector of length m if mode = 2.
% References
%   B. Efron, T. Hastie, I. Johnstone and R. Tibshirani, 
%   "Least Angle Regression", Annals of Statistics, 32, 407-499, 2004
% See Also
%   SolveOMP, SolveBP, SolveStOMP
%

explicitA = ~(ischar(A) || isa(A, 'function_handle'));
n = length(y);
if (explicitA) & (nargin < 3)
    N = size(A,2);
end

if nargin < 10,
    OptTol = 1e-5;
end
if nargin < 9,
    verbose = 0;
end
if nargin < 8,
    solFreq = 0;
end
if nargin < 7,
    resStop = 0;
end
if nargin < 6,
    lambdaStop = 0;
end
if nargin < 5,
    maxIters = 10*n;
end
if nargin < 4,
    algType = 'lasso';
end

switch lower(algType)
    case 'lars'
        isLasso = 0; nonNegative = 0;
    case 'nnlars'
        isLasso = 0; nonNegative = 1;
    case 'lasso'
        isLasso = 1; nonNegative = 0;
    case 'nnlasso'
        isLasso = 1; nonNegative = 1;
end

% Global variables for linsolve function
global opts opts_tr zeroTol
opts.UT = true; 
opts_tr.UT = true; opts_tr.TRANSA = true;
zeroTol = 1e-5;

x = zeros(N,1);
iter = 0;

% First vector to enter the active set is the one with maximum correlation
if (explicitA)
    corr = A'*y;             
else
    corr = feval(A,2,n,N,y,1:N,N); % = A'*y             
end
if (nonNegative)
    lambda = max(corr);
    if (lambda < 0)
        error('y is not expressible as a non-negative linear combination of the columns of A');
    end
    newIndices = find(abs(corr-lambda) < zeroTol)';    
else
    lambda = max(abs(corr));
    newIndices = find(abs(abs(corr)-lambda) < zeroTol)';    
end

collinearIndices = [];
sols = [];
duals = [];
res = y;
% Check stopping conditions
if ((lambdaStop > 0) & (lambda < lambdaStop)) | ((resStop > 0) & (norm(res) < resStop))
    activationHist = [];
    numIters = 0;
    return;
end

% Initialize Cholesky factor of A_I
R_I = [];
activeSet = [];
for j = 1:length(newIndices)
    iter = iter+1;
    [R_I, flag] = updateChol(R_I, n, N, A, explicitA, activeSet, newIndices(j));
    activeSet = [activeSet newIndices(j)];
    if verbose
        fprintf('Iteration %d: Adding variable %d\n', iter, activeSet(j));
    end
end
activationHist = activeSet;

done = 0;
while  ~done
    if nonNegative
        lambda = corr(activeSet(1));
    else
        lambda = abs(corr(activeSet(1)));
    end
    % Compute Lars direction - Equiangular vector
    dx = zeros(N,1);
    % Solve the equation (A_I'*A_I)dx_I = sgn(corr_I)   
    z = linsolve(R_I,sign(corr(activeSet)),opts_tr);
    dx(activeSet) = linsolve(R_I,z,opts);
    if (explicitA)
        v = A(:,activeSet)*dx(activeSet);
        ATv = A'*v;
    else
        v = feval(A,1,n,length(activeSet),dx(activeSet),activeSet,N); 
        ATv = feval(A,2,n,N,v,1:N,N); 
    end

    % For Lasso, Find first active vector to violate sign constraint
    if isLasso
        % Avoid division by zero by looking only at non-zero search directions
        posInd = find(abs(dx(activeSet)) > zeroTol);
        zc = -x(activeSet(posInd))./dx(activeSet(posInd));
        gammaI = min([zc(zc > zeroTol); inf]);
        removeIndices = activeSet(find(zc == gammaI));
    else
        gammaI = Inf;
        removeIndices = [];
    end

    % Find first inactive vector to enter the active set
    inactiveSet = 1:N;
    inactiveSet(activeSet) = 0;
    inactiveSet(collinearIndices) = 0;
    inactiveSet = find(inactiveSet > 0);
    
    if (length(inactiveSet) == 0)
        gammaIc = 1;
        newIndices = [];
    else
        epsilon = 1e-12; 
        gammaArr = (lambda - corr(inactiveSet))./(1 - ATv(inactiveSet) + epsilon);
        if ~nonNegative
            gammaArr = [gammaArr (lambda + corr(inactiveSet))./(1 + ATv(inactiveSet) + epsilon)]';
        end
        gammaArr(gammaArr < zeroTol) = Inf;
        if ~nonNegative
            gammaArr = min(gammaArr)';
        end
        [gammaIc, Imin] = min(gammaArr);
        newIndices = inactiveSet(find(abs(gammaArr - gammaIc) < zeroTol));
    end

    gammaMin = min(gammaIc,gammaI);

    % Compute the next Lars step
    x = x + gammaMin*dx;
    res = res - gammaMin*v;
    corr = corr - gammaMin*ATv;

    % Check stopping condition
    if ((lambda - gammaMin) < OptTol) | ((lambdaStop > 0) & (lambda <= lambdaStop)) | ((resStop > 0) & (norm(res) <= resStop))
        newIndices = [];
        removeIndices = [];
        done = 1;
    end

    % Add new indices to active set
    if (gammaIc <= gammaI) && (length(newIndices) > 0)
        for j = 1:length(newIndices)
            iter = iter+1;
            if verbose
                fprintf('Iteration %d: Adding variable %d\n', iter, newIndices(j));
            end
            % Update the Cholesky factorization of A_I
            [R_I, flag] = updateChol(R_I, n, N, A, explicitA, activeSet, newIndices(j));
            % Check for collinearity
            if (flag)
                collinearIndices = [collinearIndices newIndices(j)];
                if verbose
                    fprintf('Iteration %d: Variable %d is collinear\n', iter, newIndices(j));
                end
            else
                activeSet = [activeSet newIndices(j)];
                activationHist = [activationHist newIndices(j)];
            end
        end
    end

    % Remove violating indices from active set
    if (gammaI <= gammaIc)
        for j = 1:length(removeIndices)
            iter = iter+1;
            col = find(activeSet == removeIndices(j));
            if verbose
                fprintf('Iteration %d: Dropping variable %d\n', iter, removeIndices(j));
            end
            % Downdate the Cholesky factorization of A_I
            R_I = downdateChol(R_I,col);
            activeSet = [activeSet(1:col-1), activeSet(col+1:length(activeSet))];
            
            % Reset collinear set
            collinearIndices = [];
        end

        x(removeIndices) = 0;  % To avoid numerical errors
        activationHist = [activationHist -removeIndices];
    end

    if iter >= maxIters
        done = 1;
    end

    if done | ((solFreq > 0) & (~mod(iter,solFreq)))
        sols = [sols x];
        duals = [duals v];
    end
    
    if verbose
        fprintf('lambda = %3.2f, |I| = %d, normres = %3.2f\n', lambda, length(activeSet), norm(res));
    end
end

numIters = iter;
clear opts opts_tr zeroTol


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R, flag] = updateChol(R, n, N, A, explicitA, activeSet, newIndex)
% updateChol: Updates the Cholesky factor R of the matrix 
% A(:,activeSet)'*A(:,activeSet) by adding A(:,newIndex)
% If the candidate column is in the span of the existing 
% active set, R is not updated, and flag is set to 1.

global opts_tr zeroTol
flag = 0;

if (explicitA)
    newVec = A(:,newIndex);
else
    e = zeros(N,1);
    e(newIndex) = 1;
    newVec = feval(A,1,n,N,e,1:N,N); 
end

if length(activeSet) == 0,
    R = sqrt(sum(newVec.^2));
else
    if (explicitA)
        p = linsolve(R,A(:,activeSet)'*A(:,newIndex),opts_tr);
    else
        AnewVec = feval(A,2,n,length(activeSet),newVec,activeSet,N);
        p = linsolve(R,AnewVec,opts_tr);
    end
    q = sum(newVec.^2) - sum(p.^2);
    if (q <= zeroTol) % Collinear vector
        flag = 1;
    else
        R = [R p; zeros(1, size(R,2)) sqrt(q)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function R = downdateChol(R, j)
% downdateChol: `Downdates' the cholesky factor R by removing the 
% column indexed by j.

% Remove the j-th column
R(:,j) = [];
[m,n] = size(R);

% R now has nonzeros below the diagonal in columns j through n.
% We use plane rotations to zero the 'violating nonzeros'.
for k = j:n
    p = k:k+1;
    [G,R(p,k)] = planerot(R(p,k));
    if k < n
        R(p,k+1:n) = G*R(p,k+1:n);
    end
end

% Remove last row of zeros from R
R = R(1:n,:);

