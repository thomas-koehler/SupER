% Regularized sparse coding
%

clear all; close all; clc;

addpath('data');
addpath('L1REG');
addpath('sc2');

load('mnist_patches_100000.mat');

nBases = 128;
Sigma = construct_reg_mat(nBases, 'Tikhonov');
beta = 1e-1;
gamma = 0.1;
num_iters = 50;

[B, S, stat] = reg_sparse_coding(X_total, nBases, Sigma, beta, gamma, num_iters);

display_network_nonsqure2(B);