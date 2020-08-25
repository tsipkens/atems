
clear;
close all;
clc;

% [Imgs,imgs,pixsize] = tools.load_imgs; % OPTION 1: load a single image
% load('temp/b/Imgs.mat'); % OPTION 2: load preset Imgs
[Imgs,imgs,pixsize] = tools.load_imgs('images'); % OPTION 3: load all images in 'images' folder
fname = {Imgs.fname};

%-- Run thresholding for all of the images -------------------------------%
[imgs_binary, img_kmeans, feature_set] = agg.seg_kmeans6(Imgs);
% imgs_binary = agg.seg_otsu_rb(imgs, pixsize);



Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsize, fname);
    % determine aggregate properties

    

%-- Generate plots of images ---------------------------------------------%
close all; % close pre-existing images

figure(1);
[~, imgs_agg] = ...
    tools.plot_aggregates(Aggs, [], 1); % plot aggregates

% Optional command to write binary images to files
% tools.write_images(imgs_agg, fname, 'temp\b\binary');



%-{
%== Read and visualization manual binaries ===============================%
% read in adaptive manual binaries
imgs_binary0{length(imgs)} = [];

% Read in manual binary images
for ii=1:length(imgs)
    imgs_binary0{ii} = imread(['..\data\test\binary[ts]\',fname{ii}]);
end
    
Aggs0 = agg.analyze_binary(...
    imgs_binary0, imgs, pixsize, fname);

figure(2);
[~, imgs_agg0] = tools.plot_aggregates( ...
	Aggs0, jj, 1, opts); % plot aggregates

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



