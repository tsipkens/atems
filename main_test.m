
clear;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
imgs = {Imgs.cropped};

%%
% [imgs_binary] = ...
%     agg_segment.agg_det_test(Imgs);
[imgs_binary,img_kmeans,feature_set] = ...
    agg_segment.agg_det_kmeans2(Imgs);

figure(1);
tools.plot_binary_overlay(imgs{1},imgs_binary);

figure(2);
tools.plot_binary_overlay(imgs{1},img_kmeans);

figure(3);
montage(feature_set);

% figure(4);
% i10 = bwmorph(imgs_binary,'skel',inf);
% tools.plot_binary_overlay(imgs{1},i10);

figure(6);
imshow(imgs{1});
