
% MAIN_AUTO  Tests and compares multiple automated segmentation methods for CI.
% Author: Timothy Sipkens, 2020-8-25
%=========================================================================%

% Load online image.
[Imgs, imgs, pixsizes] = tools.load_imgs( ...
    'https://raw.githubusercontent.com/tsipkens/atems/master/images/201805A_A6_004.TIF'); % load first image in 'images' folder

fname = {Imgs.fname};



%== Run thresholding for all of the images ===============================%
% k-means
[imgs_km] = agg.seg_kmeans(Imgs);
Aggs_km = agg.analyze_binary(imgs_km, imgs, pixsizes, fname);

% New Otsu
imgs_otsu = agg.seg_otsu(imgs, pixsizes);
Aggs_otsu = agg.analyze_binary(imgs_otsu, imgs, pixsizes, fname);

% Original Otsu
imgs_otsu_o = agg.seg_otsu_orig(imgs, pixsizes);
Aggs_otsu_o = agg.analyze_binary(imgs_otsu_o, imgs, pixsizes, fname);
%=========================================================================%




%== Primary particle sizing ==============================================%
Aggs_pp = pp.edm_sbs(Aggs_km);
Aggs_pp = pp.kook2(Aggs_pp, 0);
Aggs_pp = pp.pcm(Aggs_pp);
%=========================================================================%




