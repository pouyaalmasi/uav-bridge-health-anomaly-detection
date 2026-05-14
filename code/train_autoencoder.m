clc;
clear;
close all;

% === LOAD CLEAN PATCHES ===
data = load('patches_patches.mat');  % Or 'filtered_patches.mat'
allFiltered = data.allPatchesMatrix; % [64 x 64 x N]

% === PREPARE DATA ===
[H, W, N] = size(allFiltered);       % Should be 64 x 64 x N
X = reshape(allFiltered, H*W, N);    % Correct: [4096 x N], each column is a patch
X = double(X) / 255;                 % Normalize

% === TRAIN AUTOENCODER ===
hiddenSize = 200;  % Tune this as needed

autoenc = trainAutoencoder(X, ...
    hiddenSize, ...
    'MaxEpochs', 200, ...
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'ScaleData', false);

% === SAVE MODEL ===
save('autoencoder_model.mat', 'autoenc');

fprintf('Autoencoder trained and saved as autoencoder_model.mat\n');
