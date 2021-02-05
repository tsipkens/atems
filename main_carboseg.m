
% MAIN_CARBOSEG  A script to explicitly test the carboseg method. 
% Test is performed on the sample images, by default. 
% AUTHOR: Timothy Sipkens, 2021-01-05
%=========================================================================%

clear;
close all;
clc;


% Load python environment. 
% Comment if Python is already loaded.
% Uncomment if Python is not loaded.
tools.load_python;


% Load images.
[Imgs, imgs, pixsizes] = tools.load_imgs('images'); % OPTION 3: load all images in 'images' folder
fname = {Imgs.fname}; % cell array of file names


%== Run CARBOSEG for all of the images ===================================%
imgs_binary = agg.seg_carboseg(imgs, pixsizes);

Aggs = agg.analyze_binary(...
    imgs_binary, pixsizes, imgs, fname, 0); % determine aggregate properties

%-- Generate plots of images ---------------------------------------------%
f1 = figure(1); f1.WindowState = 'maximized';
opts.cmap = [139, 10, 165] ./ 255; % red overlay

% Plot for output to veiwer.
tools.imshow_agg(Aggs, [], 1, opts); % tiled plot aggregates
commandwindow; % return focus to Matlab window
%=========================================================================%
