%% prediction_inference.m
% Bridge Deck Health Evaluation using Sparse Autoencoder-Based Anomaly Mapping
%
% Author: Pouya Almasi
%
% Description:
% This script loads a trained sparse autoencoder, processes UAV-acquired
% bridge deck images, computes patch-wise reconstruction errors, generates
% anomaly heatmap overlays, and reports bridge-level anomaly metrics.
%
% Notes:
% - The model should be trained on healthy concrete patches.
% - Input images should be placed in the sample_images folder.
% - The trained model should be saved as model/autoencoder_model.mat.
% - Outputs are saved in sample_results.

clc;
clear;
close all;

%% Settings

testImageDir = "../sample_images";
modelPath    = "../model/autoencoder_model.mat";
outputDir    = "../sample_results";

patchSize = 64;
threshold = 0.015;

if ~exist(outputDir, "dir")
    mkdir(outputDir);
end

%% Load Trained Autoencoder

if ~isfile(modelPath)
    error("Model file not found: %s", modelPath);
end

modelData = load(modelPath);

if isfield(modelData, "autoenc")
    autoenc = modelData.autoenc;
else
    error("The MAT file must contain a trained sparse autoencoder variable named 'autoenc'.");
end

%% Load Image Files

imageFilesJPG = dir(fullfile(testImageDir, "*.jpg"));
imageFilesPNG = dir(fullfile(testImageDir, "*.png"));
imageFilesJPEG = dir(fullfile(testImageDir, "*.jpeg"));

imageFiles = [imageFilesJPG; imageFilesPNG; imageFilesJPEG];

if isempty(imageFiles)
    error("No image files found in: %s", testImageDir);
end

%% Initialize Bridge-Level Metrics

allErrors = [];
totalAnomalous = 0;
totalPatches = 0;
totalSeverity = 0;

%% Process Images

for imgIdx = 1:numel(imageFiles)

    imgName = imageFiles(imgIdx).name;
    imgPath = fullfile(testImageDir, imgName);

    fprintf("Processing %s...\n", imgName);

    %% Read Image

    I = imread(imgPath);

    if size(I, 3) == 3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end

    Igray = im2uint8(Igray);

    [h, w] = size(Igray);

    %% Patch Grid

    nRows = floor(h / patchSize);
    nCols = floor(w / patchSize);

    if nRows == 0 || nCols == 0
        warning("Skipping %s because it is smaller than the patch size.", imgName);
        continue;
    end

    errorMap = zeros(nRows, nCols);

    %% Patch-Wise Reconstruction Error

    for i = 1:nRows
        for j = 1:nCols

            rowStart = (i - 1) * patchSize + 1;
            colStart = (j - 1) * patchSize + 1;

            patch = Igray( ...
                rowStart:rowStart + patchSize - 1, ...
                colStart:colStart + patchSize - 1);

            inputVec = double(reshape(patch, [], 1)) / 255;

            reconVec = predict(autoenc, inputVec);

            mseError = mean((inputVec - reconVec).^2);

            errorMap(i, j) = mseError;

        end
    end

    %% Image-Level Metrics

    patchErrors = errorMap(:);

    numAnomalous = sum(patchErrors > threshold);
    imageSeverity = sum(patchErrors(patchErrors > threshold) - threshold);

    allErrors = [allErrors; patchErrors];

    totalAnomalous = totalAnomalous + numAnomalous;
    totalPatches = totalPatches + numel(patchErrors);
    totalSeverity = totalSeverity + imageSeverity;

    %% Create Heatmap Overlay

    resizedMap = imresize(errorMap, size(Igray), "bicubic");
    resizedMap = mat2gray(resizedMap);

    rgbImage = repmat(Igray, 1, 1, 3);
    rgbImage = im2double(rgbImage);

    heatmapRGB = ind2rgb(uint8(resizedMap * 255), hot(256));

    alpha = 0.5;
    blended = (1 - alpha) * rgbImage + alpha * heatmapRGB;

    %% Display Result

    figure("Name", imgName);
    imshow(blended);
    colormap hot;
    colorbar;
    title("Anomaly Heatmap: " + string(imgName), "Interpreter", "none");

    %% Save Result

    [~, baseName, ~] = fileparts(imgName);

    outputPath = fullfile(outputDir, "heatmap_" + string(baseName) + ".png");

    imwrite(blended, outputPath);

end

%% Final Bridge-Level Metrics

avgError = mean(allErrors);
percentAnomalous = (totalAnomalous / totalPatches) * 100;
severityScore = totalSeverity / totalPatches;

[conditionClass, nbiRating] = classifyBridgeCondition( ...
    avgError, ...
    percentAnomalous, ...
    severityScore);

%% Report

fprintf("\n===== OVERALL BRIDGE REPORT =====\n");
fprintf("Total Images: %d\n", numel(imageFiles));
fprintf("Total Patches: %d\n", totalPatches);
fprintf("Average Reconstruction Error: %.4f\n", avgError);
fprintf("Anomalous Area (> %.3f): %.2f %%\n", threshold, percentAnomalous);
fprintf("Severity Score: %.4f\n", severityScore);
fprintf("Estimated Condition: %s\n", conditionClass);
fprintf("Estimated NBI-Aligned Rating: %d\n", nbiRating);
fprintf("Results saved in: %s\n", outputDir);

%% Local Function

function [conditionClass, nbiRating] = classifyBridgeCondition(avgErr, percentAnomalous, severityScore)

    conditionClass = "Unknown";
    nbiRating = -1;

    if avgErr <= 0.0020 && percentAnomalous <= 5 && severityScore <= 0.0005
        conditionClass = "Excellent";
        nbiRating = 9;

    elseif avgErr <= 0.0035 && percentAnomalous <= 10 && severityScore <= 0.0010
        conditionClass = "Very Good";
        nbiRating = 8;

    elseif avgErr <= 0.0050 && percentAnomalous <= 15 && severityScore <= 0.0020
        conditionClass = "Good";
        nbiRating = 7;

    elseif avgErr <= 0.0100 && percentAnomalous <= 30 && severityScore <= 0.0035
        conditionClass = "Satisfactory";
        nbiRating = 6;

    elseif avgErr <= 0.0150 && percentAnomalous <= 45 && severityScore <= 0.0055
        conditionClass = "Fair";
        nbiRating = 5;

    elseif avgErr <= 0.0200 || percentAnomalous <= 60
        conditionClass = "Poor";
        nbiRating = 4;

    else
        conditionClass = "Critical";
        nbiRating = 1;
    end

end