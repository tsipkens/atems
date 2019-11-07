
clear;
close all;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
imgs = {Imgs.cropped};

%%
[imgs_binary] = ...
    agg_segment.agg_det_kmeans_rb(Imgs);

tools.plot_binary_overlay(imgs{1},imgs_binary);
