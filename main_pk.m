
clear;
close all;
clc;

Imgs = tools.load_imgs; % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fnames = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
opts.bool_kmeans = 0;
opts.bool_otsu = 0;
imgs_binary = ...
    agg.perform_seg(imgs,pixsize,opts);
tools.write_images(imgs_binary,fnames,['images',filesep,'binary']);


%-- Get aggregate properties (e.g. Rg) -----------------------------------%
Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fnames);
        % determine aggregate properties


%-- Analyze primary particles --------------------------------------------%
Aggs_pcm = pp.pcm(Aggs); % apply PCM

Aggs_edm = pp.edm_sbs(Aggs_pcm);
    % apply Euclidean distance mapping-surface based scale analysis

% Aggs_kook = pp.kook(Imgs,1); % kook method, normally underperforms



tools.write_excel(Aggs_edm,'data\Aggs.xlsx');
    % write results to an excel file


figure(1);
tools.plot_aggregates(Aggs_pcm);
    % generate a plot of the first image
    % highlighting the segmented aggregate 
    % and showing the PCM diameter



