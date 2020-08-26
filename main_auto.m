
% MAIN_AUTO  Tests and compares multiple automated segmentation methods.
% Author: Timothy Sipkens, 2020-8-25
%=========================================================================%

clear;
close all;
clc;

[Imgs,imgs,pixsizes] = tools.load_imgs('images'); % load all images in 'images' folder

fname = {Imgs.fname};



%== Run thresholding for all of the images ===============================%
% k-means
[imgs_km] = agg.seg_kmeans6(Imgs);
Aggs_km = agg.analyze_binary(imgs_km, imgs, pixsizes, fname);
figure(1);
tools.imshow_agg(Aggs_km);
commandwindow;

% New Otsu
imgs_otsu = agg.seg_otsu_rb(imgs, pixsizes);
Aggs_otsu = agg.analyze_binary(imgs_otsu, imgs, pixsizes, fname);
figure(2);
tools.imshow_agg(Aggs_otsu);
commandwindow;

% Original Otsu
imgs_otsu_o = agg.seg_otsu_rb_orig(imgs, pixsizes);
Aggs_otsu_o = agg.analyze_binary(imgs_otsu_o, imgs, pixsizes, fname);
figure(3);
tools.imshow_agg(Aggs_otsu_o);
commandwindow;
%=========================================================================%




%== Primary particle sizing ==============================================%
Aggs_pp = pp.edm_sbs(Aggs_km);
Aggs_pp = pp.kook2(Aggs_pp);
Aggs_pp = pp.pcm(Aggs_pp);

figure(10);
loglog([Aggs_pp.dp_pcm1], [Aggs_pp.dp_edm], '.');
hold on;
loglog([Aggs_pp.dp_pcm1], [Aggs_pp.dp_kook], '.');
ylims = ylim;  plot(ylims, ylims, 'k-'); % 1:1 line
hold off;
%=========================================================================%




