
clear;
close all;
clc;


%-- Load images ----------------------------------------------------------%
[Imgs, imgs, pixsize] = tools.load_imgs; % load a single image
fname = {Imgs.fname};
%-------------------------------------------------------------------------%


%-- Run thresholding for all of the images -------------------------------%
opts.bool_kmeans = 1;
opts.bool_otsu = 0;
imgs_binary = agg.seg(imgs, pixsize, opts);

Aggs = agg.analyze_binary(imgs_binary, ...
    imgs, pixsize, fname); % determine aggregate properties
%-------------------------------------------------------------------------%


%-- Compute the primary particle size ------------------------------------%
Aggs_pcm = pp.pcm(Aggs); % apply PCM
Aggs_edm = pp.edm_sbs(Aggs_pcm); % apply EDM-SBS (overwrites Aggs.dp)

tools.write_excel(Aggs_edm, 'temp\Aggs.xlsx'); % write data to Excel file
%-------------------------------------------------------------------------%



figure(1);
tools.imshow_agg(Aggs_edm);



figure(4);
loglog([Aggs_pcm.dp], [Aggs_edm.dp], '.');
hold on;
loglog(xlim,xlim);
hold off;

xlabel('PCM, dp [nm]');
ylabel('EDM-SBS, dp [nm]');


