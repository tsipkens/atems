
clear;
close all;
clc;

Imgs = tools.load_imgs; % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
opts.bool_kmeans = 1;
opts.bool_otsu = 0;
imgs_binary = ...
    agg.multi_seg(imgs,pixsize,opts);
[Imgs.binary] = imgs_binary{:};

% for ii=1:length(Imgs)
%     imgs_binary{ii} = ...
%         imread(['..\images\test\binary_manual\',fname{ii}]);
% end


Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties


Aggs_pcm = pp.pcm(Aggs);


Aggs_edm = pp.edm_sbs(Aggs_pcm);
tools.write_excel(Aggs_edm,'data\Aggs.xlsx');


% Aggs_kook = pp.kook(Imgs,1);


figure(1);
tools.plot_aggregates(Aggs_edm);



figure(4);
loglog([Aggs_edm.dp_pcm_simple],real([Aggs_edm.dpg_edm]),'.');
hold on;
loglog(xlim,xlim);
hold off;

xlabel('PCM, dp [nm]');
ylabel('EDM-SBS, dp [nm]');


