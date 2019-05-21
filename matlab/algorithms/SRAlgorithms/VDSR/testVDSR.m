run('matconvnet/matlab/vl_setupnn.m');
addpath('util/');

outDir = 'result'; % output directory
data = 'Set5';     % test data (directory) which is in data folder 
SF = 2;            % test scale factors. can be 2, 3 or 4
outRoute = fullfile(outDir, data, ['VDSR_x',num2str(SF)]);

if ~exist(outRoute, 'dir')
    mkdir(outRoute);
end

%VDSR(data, SF, 'VDSR.mat', outRoute);
VDSR(data, SF, 'VDSR_CPUonly_SupER.mat', outRoute); % MAGI-ADAPT
