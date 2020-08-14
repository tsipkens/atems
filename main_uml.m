

clear;
close all;
clc;

%{
Imgs_ref = tools.get_img_ref; % get location of files

Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
%}

load('temp/b/Imgs.mat'); % load preset Imgs

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
[imgs_binary, img_kmeans, feature_set] = agg.seg_kmeans6(imgs, pixsize);
% imgs_binary = agg.seg_kmeans2(imgs, pixsize);
% imgs_binary = agg.seg_otsu_rb(imgs, pixsize);



Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsize, fname);
    % determine aggregate properties


%-- Generate plots of images ---------%
close all; % close pre-existing images
for ii=1:length(imgs) % loop through images
    jj = find(strcmp(fname{ii}, {Aggs.fname})); % find instance of aggregate in given image
    jj = jj(1);
    
    figure(ii+2);
    opts.cmap = [0.92,0.16,0.49];
    % opts.cmap = [0.12,0.59,0.96];
    [~, imgs_agg{ii}] = tools.plot_aggregates( ...
        Aggs, jj, 1, opts); % plot aggregates
end

tools.write_images(imgs_agg, fname, 'temp\b\otsu_o');



%{
%== Read and visualization manual binaries ===============================%
% read in adaptive manual binaries
imgs_binary0{length(imgs)} = [];

for ii=1:length(imgs)
    imgs_binary0{ii} = imread(['..\data\test\binary[ts]\',fname{ii}]);
end
    
Aggs0 = agg.analyze_binary(...
    imgs_binary0, imgs, pixsize, fname);

for ii=1:length(imgs)
    jj = find(strcmp(fname{ii}, {Aggs0.fname})); % find instance of aggregate in given image
    jj = jj(1);
    
    figure(1);
    opts.cmap = [0.99,0.86,0.37];
        [~, imgs_agg0{ii}] = tools.plot_aggregates( ...
        Aggs0, jj, 1, opts); % plot aggregates
end

% plot and write manual binary images
tools.write_images(imgs_agg0, fname, 'temp\b\man');
%=========================================================================%
%}