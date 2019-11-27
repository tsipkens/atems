
clear;
close all;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
opts.bool_kmeans = 0;
opts.bool_otsu = 0;
imgs_binary = ...
    agg.perform_seg(imgs,pixsize,opts);
[Imgs.binary] = imgs_binary{:};


%-- Get aggregate properties (e.g. Rg) -----------------------------------%
Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties


Aggs_pcm = pp.pcm(Aggs);


Aggs_edm = pp.edm_sbs(Aggs_pcm);
tools.write_excel('data\Aggs.xlsx',Aggs_edm);
    % write data to an excel file


% Aggs_kook = pp.kook(Imgs,1);


figure(1);
tools.plot_aggregates(Aggs_pcm);



