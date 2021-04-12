
% MAIN_CARBOSEG_EXT  A script to test the carboseg method, using external saves.
%  This differs from main_carboseg in that it saves and loads images for
%  processing by external Python IDE.
%  
%  AUTHOR: Timothy Sipkens, 2021-01-05
%=========================================================================%


clear;
close all;
clc;


% Load images.
[Imgs, imgs, pixsizes] = tools.load_imgs('images'); % use 'images' folder
fnames = {Imgs.fname}; % cell array of file names


% Write images to input folder.
fnames_png = agg.seg_ext(imgs, fnames, 'carboseg/input', 'png');


% Wait for external processing in Python.
% Press any key to continue when Python processing completed.
disp('Waiting for external processing in Python.');
disp('Press any key when done to continue ...');
pause;
tools.textdone(2);


% Read in files and apply rolling ball transform.
imgs_binary = agg.seg_cnn_pt2(fnames_png, 'carboseg/output', pixsizes);


% Continue with post-processing...
Aggs = agg.analyze_binary(...
    imgs_binary, pixsizes, imgs, fnames, 0); % determine aggregate properties

%-- Generate plots of images ---------------------------------------------%
f1 = figure(1); f1.WindowState = 'maximized';
opts.cmap = [139, 10, 165] ./ 255; % red overlay

% Plot for output to veiwer.
tools.imshow_agg(Aggs, [], 1, opts); % tiled plot aggregates
commandwindow; % return focus to Matlab window
%=========================================================================%
