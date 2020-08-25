
clear;
close all;
clc;

% [Imgs,imgs,pixsize] = tools.load_imgs; % OPTION 1: load a single image
% load('temp/b/Imgs.mat'); % OPTION 2: load preset Imgs
[Imgs,imgs,pixsize] = tools.load_imgs('images'); % OPTION 3: load all images in 'images' folder

fname = {Imgs.fname};




%== Run a thresholding for all of the images =============================%
[imgs_binary, img_kmeans, feature_set] = agg.seg_kmeans6(Imgs);
% imgs_binary = agg.seg_otsu_rb(imgs, pixsize);

Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsize, fname);
    % determine aggregate properties

% Generate plots of images.
close all; % close pre-existing images
figure(1);
opts.cmap = [0.92,0.16,0.49]; % red overlay
[~, imgs_agg] = tools.imshow_agg(Aggs, [], 1, opts); % plot aggregates
commandwindow; % return focus to Matlab window

% Optional command to write binary images to files
tools.write_images(imgs_agg, fname, 'temp\b\test\binary');
%=========================================================================%




%-{
%== Read and visualization manual binaries ===============================%
% read in adaptive manual binaries
imgs_binary0{length(imgs)} = [];

% Read in manual binary images
for ii=1:length(imgs)
    imgs_binary0{ii} = imread(['..\data\test\binary[ts]\',fname{ii}]);
end

Aggs0 = agg.analyze_binary(imgs_binary0, ...
    imgs, pixsize, fname); % analyze manual binaries

% Overlay binaries from separate manual analysis.
figure(2);
opts.cmap = [0.99,0.86,0.37]; % yellow overlay
[~, imgs_agg0] = tools.imshow_agg(Aggs0, [], 1, opts);
commandwindow; % return focus to Matlab window

% plot and write manual binary images
tools.write_images(imgs_agg0, fname, 'temp\b\manual');

% compute IoU
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
plot(ylims, ylims);
hold off;
%=========================================================================%
%}



