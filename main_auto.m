
% MAIN_AUTO  Tests and compares multiple automated segmentation methods.
% Runtime should be less than a minute.
% Author: Timothy Sipkens, 2020-8-25
%=========================================================================%

clear;
close all;
clc;

[Imgs, imgs, pixsizes] = tools.load_imgs('images', 1); % load first image in 'images' folder

fname = {Imgs.fname};



%== Run thresholding for all of the images ===============================%
% k-means
[imgs_km] = agg.seg_kmeans(Imgs);
Aggs_km = agg.analyze_binary(imgs_km, imgs, pixsizes, fname);
f1 = figure(1); f1.WindowState = 'maximized'; title('k-means');
opts.cmap = [0.92,0.16,0.49]; % red overlay
tools.imshow_agg(Aggs_km, [], [], opts);
title('k-means');
commandwindow;

% New Otsu
imgs_otsu = agg.seg_otsu(imgs, pixsizes);
Aggs_otsu = agg.analyze_binary(imgs_otsu, imgs, pixsizes, fname);
f2 = figure(2); f2.WindowState = 'maximized'; title('Otsu');
tools.imshow_agg(Aggs_otsu);
title('Otsu');
commandwindow;

% Original Otsu
imgs_otsu_o = agg.seg_otsu_orig(imgs, pixsizes);
Aggs_otsu_o = agg.analyze_binary(imgs_otsu_o, imgs, pixsizes, fname);
f3 = figure(3); f3.WindowState = 'maximized'; title('Otsu (orig.)');
tools.imshow_agg(Aggs_otsu_o);
title('Otsu, original');
commandwindow;
%=========================================================================%




%== Primary particle sizing ==============================================%
Aggs_pp = pp.edm_sbs(Aggs_km);
Aggs_pp = pp.kook2(Aggs_pp, 0);
Aggs_pp = pp.pcm(Aggs_pp);
%=========================================================================%




