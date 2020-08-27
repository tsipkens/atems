
clear;
close all;
clc;

% [Imgs,imgs,pixsize] = tools.load_imgs; % OPTION 1: load a single image
% load('temp/b/Imgs.mat'); % OPTION 2: load preset Imgs
[Imgs,imgs,pixsizes] = tools.load_imgs('images'); % OPTION 3: load all images in 'images' folder

fname = {Imgs.fname};




%== Run thresholding for all of the images ===============================%
[imgs_binary, img_kmeans, feature_set] = agg.seg_kmeans(Imgs);
% imgs_binary = agg.seg_otsu_rb(imgs, pixsizes);

Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsizes, fname, 0); % determine aggregate properties

%-- Generate plots of images ---------------------------------------------%
f1 = figure(1); f1.WindowState = 'maximized';
opts.cmap = [0.92,0.16,0.49]; % red overlay

% Get higher res. aggregate plots for saving.
%{
imgs_agg{length(imgs)} = []; % initialize cell
for ii=1:length(imgs)
    [~, imgs_agg{ii}] = tools.imshow_agg(Aggs, ii, 1, opts);
end
tools.write_images(imgs_agg, fname, 'temp\b\kmeans');
%}

% Plot for output to veiwer.
[~, imgs_agg] = tools.imshow_agg(Aggs, [], 1, opts); % tiled plot aggregates
pause(0.05);
commandwindow; % return focus to Matlab window
%=========================================================================%




%{
%== Read and visualization MANUAL binaries ===============================%
% read in adaptive manual binaries
imgs_binary0{length(imgs)} = [];

% Read in manual binary images
for ii=1:length(imgs)
    imgs_binary0{ii} = imread(['..\data\test\binary[ts]\',fname{ii}]);
end

Aggs0 = agg.analyze_binary(imgs_binary0, ...
    imgs, pixsizes, fname); % analyze manual binaries

%-- Generate plots of images ---------------------------------------------%
f2 = figure(2); f2.WindowState = 'maximized';
opts.cmap = [0.99,0.86,0.37]; % yellow overlay

% Get higher res. aggregate plots for saving.
%{
imgs_agg0{length(imgs)} = []; % initialize cell
for ii=1:length(imgs)
    [~, imgs_agg0{ii}] = tools.imshow_agg(Aggs0, ii, 1, opts);
end
tools.write_images(imgs_agg0, fname, 'temp\b\manual'); % write manual binary images
%}

% Plot for output to veiwer.
[~, imgs_agg0] = tools.imshow_agg(Aggs0, [], 1, opts); % tiled plot aggregates
pause(0.05);
commandwindow; % return focus to Matlab window


%-- Compute IoU (intersect-over-union) -----------------------------------%
i1 = [imgs_binary{:}]; i1 = i1(:);
i2 = [imgs_binary0{:}]; i2 = i2(:);
IoU = sum(and(i1,i2)) ./ sum(or(i1,i2))
%=========================================================================%
%}




%-{
%== Primary particle sizing ==============================================%
Aggs_pcm = pp.pcm(Aggs);
Aggs_edm = pp.edm_sbs(Aggs_pcm);

figure(20);
loglog([Aggs_pcm.da], [Aggs_pcm.dp_pcm1], '.');

figure(21);
loglog([Aggs_edm.dp_pcm1], [Aggs_edm.dp_edm], '.');
hold on;
ylims = ylim;
plot(ylims, ylims); % 1:1 line
hold off;
%=========================================================================%
%}



