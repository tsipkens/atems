
clear;
close all;
clc;


% Load images. 
[~, imgs, pixsizes] = tools.load_imgs('images'); % load the images


% Segment the aggregates from the background.
imgs_binary = agg.seg_kmeans(imgs, pixsizes);
    % segment aggregates


% Analyze the image binaries.
Aggs = agg.analyze_binary(...
    imgs_binary, pixsizes, imgs);
        % determine aggregate properties


% Get primary particle size. 
Aggs = pp.pcm(Aggs); % apply pair correlation method


% Show updated figure.
figure(2);
tools.imshow_agg(Aggs);