
% MAIN_CI  Tests and compares multiple automated segmentation methods for continuous integration.
% Author: Timothy Sipkens, 2020-8-25
%=========================================================================%

% Load online image.
[Imgs, imgs, pixsizes] = tools.load_imgs( ...
    'https://raw.githubusercontent.com/tsipkens/atems/master/images/201805A_A6_004.TIF'); % load first image in 'images' folder

fname = {Imgs.fname};



%== Run thresholding for all of the images ===============================%
% k-means
imgs_km = agg.seg_kmeans(Imgs);
Aggs = agg.analyze_binary(imgs_km, pixsizes, imgs, fname, [], 0);

% New Otsu
imgs_otsu = agg.seg_otsu(imgs, pixsizes);
agg.analyze_binary(imgs_otsu, pixsizes, imgs, fname, [], 0);

% Original Otsu
imgs_otsu_o = agg.seg_otsu_orig(imgs, pixsizes);
agg.analyze_binary(imgs_otsu_o, pixsizes, imgs, fname, [], 0);
%=========================================================================%




%== Primary particle sizing ==============================================%
pp.edm_sbs(Aggs);
pp.kook2(Aggs, 0);
pp.pcm(Aggs);
pp.edm_ws(Aggs, [], 0);
%=========================================================================%




