
% MAIN_AUTO  Tests and compares multiple automated segmentation methods.
% Author: Timothy Sipkens, 2020-8-25
%=========================================================================%

clear;
close all;
clc;

[Imgs, imgs, pixsizes] = tools.load_imgs('images'); % load all images in 'images' folder

% Only use the first image for testing.
Imgs = Imgs(1);
imgs = imgs{1};
pixsizes = pixsizes(1);

fname = {Imgs.fname};



%== Run thresholding for all of the images ===============================%
% k-means
[imgs_km] = agg.seg_kmeans(Imgs);
Aggs_km = agg.analyze_binary(imgs_km, imgs, pixsizes, fname);
f1 = figure(1); f1.WindowState = 'maximized'; title('k-means');
opts.cmap = [0.92,0.16,0.49]; % red overlay
tools.imshow_agg(Aggs_km, [], [], opts);
commandwindow;

% New Otsu
imgs_otsu = agg.seg_otsu(imgs, pixsizes);
Aggs_otsu = agg.analyze_binary(imgs_otsu, imgs, pixsizes, fname);
f2 = figure(2); f2.WindowState = 'maximized'; title('Otsu');
tools.imshow_agg(Aggs_otsu);
commandwindow;

% Original Otsu
imgs_otsu_o = agg.seg_otsu_orig(imgs, pixsizes);
Aggs_otsu_o = agg.analyze_binary(imgs_otsu_o, imgs, pixsizes, fname);
f3 = figure(3); f3.WindowState = 'maximized'; title('Otsu (orig.)');
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
loglog([Aggs_pp.dp_pcm1], [Aggs_pp.dp_kook], 'x');
ylims = ylim;  plot(ylims, ylims, 'k-'); % 1:1 line
xlabel('d_{p,PCM}'); ylabel('d_{p, EDM}, d_{p,kook}');
legend({'EDM-SBS', 'Kook'});
hold off;
%=========================================================================%




