

clear;
close all;
clc;

%{
Imgs_ref = tools.get_img_ref; % get location of files
% load('result/test_img_ref.mat');
    % load a reference to a set of images to be analyzed

Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
%}

load('temp/b/Imgs.mat'); % load preset Imgs

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
% imgs_binary = agg.seg_kmeans6(imgs, pixsize);
% imgs_binary = agg.seg_kmeans2(imgs, pixsize);
imgs_binary = agg.seg_otsu_rb(imgs, pixsize);



Aggs = agg.analyze_binary(...
    imgs_binary, imgs, pixsize, fname);
    % determine aggregate properties


%-- Generate plots of images ---------%
close all; % close pre-existing images
for ii=1:length(imgs) % loop through images
    jj = find(strcmp(fname{ii}, {Aggs.fname}));
    jj = jj(1);
    
    figure(ii+2);
    tools.plot_aggregates(Aggs,jj,1);
end

tools.write_images(imgs_binary,fname,'temp\b');

