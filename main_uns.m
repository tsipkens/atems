

clear;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
imgs = {Imgs.cropped};

%%
imgs_binary = {};
imgs_kmeans = {};
feature_set = {};
for ii=1:length(imgs)
    [imgs_binary{ii},imgs_kmeans{ii},feature_set{ii}] = ...
        agg.seg_kmeans2(Imgs(ii));
end


figure(1);
ind = 1;
tools.plot_binary_overlay(imgs{ind},imgs_binary{ind});


