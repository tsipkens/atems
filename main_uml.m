

clear;
close all;
clc;

Imgs_ref = tools.get_img_ref; % get location of files
% load('result/test_img_ref.mat');
    % load a reference to a set of images to be analyzed

Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
% opts.bool_kmeans = 1;
% opts.bool_otsu = 0;
% imgs_binary = agg.seg_kmeans4multi_seg(imgs,pixsize,opts);
% [Imgs.binary] = imgs_binary{:};

imgs_binary = agg.seg_kmeans3(imgs{1},pixsize);
imgs_binary = {imgs_binary};

imgs_binary2 = agg.seg_kmeans2(imgs{1},pixsize);
imgs_binary2 = {imgs_binary2};


% for ii=1:length(Imgs)
%     imgs_binary{ii} = ...
%         imread(['..\images\test\binary_manual\',fname{ii}]);
% end

figure(3);
Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties

figure(2);
Aggs2 = agg.analyze_binary(...
    imgs_binary2,imgs,pixsize,fname);
        % determine aggregate properties

tools.write_images(imgs_binary,fname,'temp');

