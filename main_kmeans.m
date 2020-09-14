
% MAIN_KMEANS  A script to explicitly test the k-means method. 
% Test is performed on the sample images, by default. 
% Optionally reads in manually binarized images. 
% Author: Timothy Sipkens
%=========================================================================%


clear;
close all;
clc;

% [Imgs,imgs,pixsizes] = tools.load_imgs; % OPTION 1: load a single image
% load('temp/Imgs.mat'); % OPTION 2: load preset Imgs
[Imgs,imgs,pixsizes] = tools.load_imgs('images'); % OPTION 3: load all images in 'images' folder

fname = {Imgs.fname}; % cell array of file names




%== Run K-MEANS for all of the images ====================================%
[imgs_binary, img_kmeans, feature_set] = agg.seg_kmeans(Imgs);
% imgs_binary = agg.seg_otsu(imgs, pixsizes);

Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsizes, fname, 0); % determine aggregate properties

%-- Generate plots of images ---------------------------------------------%
f1 = figure(1); f1.WindowState = 'maximized';
opts.cmap = [0.92,0.16,0.49]; % red overlay

% Plot for output to veiwer.
[~, imgs_agg] = tools.imshow_agg(Aggs, [], 1, opts); % tiled plot aggregates
pause(0.05);
commandwindow; % return focus to Matlab window
%=========================================================================%




%-{
%== Read and visualization SLIDER binaries ===============================%
% read in adaptive manual binaries
imgs_binary0{length(imgs)} = [];

% Read in manual binary images
for ii=1:length(imgs)
    imgs_binary0{ii} = imread(['images/slider/',fname{ii}]);
end

Aggs0 = agg.analyze_binary(imgs_binary0, ...
    imgs, pixsizes, fname, 0); % analyze manual binaries

%-- Generate plots of images ---------------------------------------------%
f2 = figure(2); f2.WindowState = 'maximized';
opts.cmap = [0.99,0.86,0.37]; % yellow overlay

% Plot for output to veiwer.
[~, imgs_agg0] = tools.imshow_agg(Aggs0, [], 1, opts); % tiled plot aggregates
pause(0.05);
commandwindow; % return focus to Matlab window


%-- Compute IoU (intersect-over-union) -----------------------------------%
i1 = [imgs_binary{:}]; i1 = i1(:);
i2 = [imgs_binary0{:}]; i2 = i2(:);
IoU = sum(and(i1,i2)) ./ sum(or(i1,i2))

%-- Compute % difference in da -------------------------------------------%
dag_diff = (mean([Aggs.da]) ./ mean([Aggs0.da]) - 1) .* 100

%-- Match aggregates and compare da --------------------------------------%
[idx_0, idx_k] = tools.match_aggs(Aggs0, Aggs);
da_diff = (1 - [Aggs0(idx_0).da] ./ [Aggs(idx_k).da]) .* 100;
da_m = median(da_diff)
da_s1 = prctile(da_diff, 2.5)
da_s2 = prctile(da_diff, 97.5)
%=========================================================================%
%}




%-{
%== Primary particle sizing ==============================================%
Aggs = pp.edm_sbs(Aggs);
Aggs = pp.pcm(Aggs);

figure(20);
tools.viz_dadp([Aggs.da], [Aggs.dp_pcm1]);
ylabel('d_{p,PCM} [nm]');

figure(21);
loglog([Aggs.dp_pcm1], [Aggs.dp_edm], '.');
hold on;
ylims = ylim;
plot(ylims, ylims); % 1:1 line
hold off;
xlabel('d_{p,PCM}');
ylabel('d_{p,EDM}');
%=========================================================================%
%}



