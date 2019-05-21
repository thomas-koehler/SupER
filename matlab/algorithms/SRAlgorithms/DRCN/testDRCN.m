% run('snu_matconvnet/setup.m');
run('snu_matconvnet/matlab/vl_setupnn.m');
addpath('util/');

outDir = 'result';  % output directory
data = 'Set5';      % test data (directory) which is in data folder
SF = 2;             % test scale factors. can be 2, 3 or 4
outRoute = fullfile(outDir, data, ['DRCN_x',num2str(SF)]);

if ~exist(outRoute, 'dir')
    mkdir(outRoute);
end

DRCN(data, SF, ['sf',num2str(SF),'/DRCN_sf',num2str(SF),'.mat'], outRoute);