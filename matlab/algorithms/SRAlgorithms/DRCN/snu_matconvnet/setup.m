% This setup is tested under Ubuntu 14.04. CUDNN needs to be copied into local directory
addpath matlab
%vl_compilenn('enableGPU', 1, 'cudaRoot', '/usr/local/cuda-7.0', 'cudaMethod', 'nvcc', 'enableCudnn', 1, 'cudnnRoot', 'local/');
%vl_compilenn('enableGPU', 1, 'cudaMethod', 'nvcc');
vl_compilenn('enableGPU', 0, 'cudaMethod', 'nvcc'); % MAGI-ADAPT
