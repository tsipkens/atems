
clear;
close all;
clc;

[Imgs, imgs, pixsize] = tools.load_imgs; % load a single image

fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
opts.bool_kmeans = 1;
opts.bool_otsu = 0;
imgs_binary = agg.seg(imgs, pixsize, opts);


Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties


Aggs_pcm = pp.pcm(Aggs); % apply PCM


Aggs_edm = pp.edm_sbs(Aggs_pcm); % apply EDM-SBS
tools.write_excel(Aggs_edm, 'temp\Aggs.xlsx');


% Aggs_kook = pp.kook(Imgs,1);


figure(1);
tools.plot_aggregates(Aggs_edm);



figure(4);
loglog([Aggs_pcm.dp], [Aggs_edm.dp], '.');
hold on;
loglog(xlim,xlim);
hold off;

xlabel('PCM, dp [nm]');
ylabel('EDM-SBS, dp [nm]');


