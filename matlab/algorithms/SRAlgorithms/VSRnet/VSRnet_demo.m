% *************************************************************************
% Video Super-Resolution with Convolutional Neural Networks
% 
% If you use this code, please cite the following publication:
%     A.Kappeler, S.Yoo, Q.Dai, A.K.Katsaggelos, "Video Super-Resolution 
%     with Convolutional Neural Networks", to appear in IEEE Transactions
%     on Computational Imaging
% 
% Installation Instructions: 
% 1) install Caffe from "http://caffe.berkeleyvision.org/"
% 2) run the following command in Matlab:
%       cd external_functions/CLG-TV-matlab
%       mex applyBilateralFilterToDataTerms.cpp
%       cd ../..
% 3) specify the CAFFEPATH on line 53 in VSRnet_demo.m
% 4) set the experiment you want to execute to "true" (only one at the time)  
%
% 
% Version 1.0
%
% Created by:   Armin Kappeler
% Date:         02/19/2016
%
% http://ivpl.eecs.northwestern.edu/software
% 
% *************************************************************************
%
% Because of the data size, we only provide a subset of our videos on the
% website. For additional testvideos and our training database, please
% contact us directly.
%
% *************************************************************************
% Copyright (C) 2016 Armin Kappeler
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% For a copy of the GNU General Public License,
% please see <http://www.gnu.org/licenses/>. 
% 
% *************************************************************************

clearvars
%% GENERAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CAFFEPATH = '/HOMES/baetz/develop/CAFFE/caffe/';   % path to caffe installation


LOW_MEMORY_MODE = 1;    % if Matlab crashes, try a higher number:
                        % 0 = high GPU memory usage -> fastest
                        % 1 = medium GPU memory usage -> fast
                        % 2 = low GPU memory usage -> slow
                        
USE_GPU = false;         % set to false, if no GPU available -> slowest
GPU_ID = 0;             % GPU ID -> should normally be 0   

%% RUN VSRnet on Video %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% specify TESTVIDEO_PATCH and UPSCALE_FACTOR and run
if true
    TESTVIDEO_PATH = 'data/lr_video/u2/foreman_LR.mat'; % path to input video frames
                                        % a variable "frames" with dimensions (width x height x nrFrames) is expected
    UPSCALE_FACTOR = 2;                 % upscale factor: 2,3,4 are available

    MOTIONCOMPENSATION = true;          % use Motion Compensation (much faster)
                                        % Note: MOTIONCOMPENSATION=false is only available for upscale factor 3
    ADAPTIVEMOTIONCOMPENSATION = false; % use Adaptive Motion Compensation
    TESTONLY1FRAME = 0;                 % 0: all frames will be tested, otherwise only one frame will be tested
    RESULTFILE_PATH = ['results/magi_quick_test'];% filename for results
    PREPROCESSED_INPUT = false;         % do not change
end

%% REPRODUCE RESULTS FROM PAPER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% these experiments reproduce the results from the paper 
% the testvideos here are already preprocessed
% do not change the parameters below this point


% Myanmar upscale factor 2
if false
    TESTVIDEO_PATH = 'data/preprocessed/u2/matTestimages_Myanmar.mat'; 
    UPSCALE_FACTOR = 2;                 

    MOTIONCOMPENSATION = true;          
    ADAPTIVEMOTIONCOMPENSATION = false; 
    TESTONLY1FRAME = 0;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

% Myanmar upscale factor 3
if false
    TESTVIDEO_PATH = 'data/preprocessed/u3/matTestimages_Myanmar.mat'; 
    UPSCALE_FACTOR = 3;                 

    MOTIONCOMPENSATION = true;          
    ADAPTIVEMOTIONCOMPENSATION = false; 
    TESTONLY1FRAME = 0;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

% Myanmar upscale factor 4
if false
    TESTVIDEO_PATH = 'data/preprocessed/u4/matTestimages_Myanmar.mat'; 
    UPSCALE_FACTOR = 4;                 

    MOTIONCOMPENSATION = true;          
    ADAPTIVEMOTIONCOMPENSATION = false; 
    TESTONLY1FRAME = 0;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

% Myanmar upscale factor 3, no motion compensation
if false
    TESTVIDEO_PATH = 'data/preprocessed/u3/matTestimages_Myanmar_noMotionCompensation.mat'; 
    UPSCALE_FACTOR = 3;                 

    MOTIONCOMPENSATION = false;          
    ADAPTIVEMOTIONCOMPENSATION = false; 
    TESTONLY1FRAME = 0;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

% Foreman, upscale factor 3, normal motion compensation (MC)
if false
    TESTVIDEO_PATH = 'data/preprocessed/u3/matTestimages_foreman.mat'; 
    UPSCALE_FACTOR = 3;                 

    MOTIONCOMPENSATION = true;          
    ADAPTIVEMOTIONCOMPENSATION = false; 
    TESTONLY1FRAME = 7;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

% Foreman, upscale factor 3, adaptive motion compensation (AMC)
if false
    TESTVIDEO_PATH = 'data/preprocessed/u3/matTestimages_foreman_adaptiveMotionCompensation.mat'; 
    UPSCALE_FACTOR = 3;                 

    MOTIONCOMPENSATION = true;          
    ADAPTIVEMOTIONCOMPENSATION = true; 
    TESTONLY1FRAME = 7;                 
    RESULTFILE_PATH = ['results/dummy'];
    PREPROCESSED_INPUT = true;          
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%% start processing
addpath('functions','external_functions/CLG-TV-matlab',[CAFFEPATH '/matlab'])
run('main_VSRnet_test.m')
run('evaluate_result.m')

