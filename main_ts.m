
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
% opts.bool_kmeans = 0;
% opts.bool_otsu = 0;
% imgs_binary = ...
%     agg.perform_seg(imgs,pixsize,opts);
% [Imgs.binary] = imgs_binary{:};

for ii=1:length(Imgs)
    imgs_binary{ii} = ...
        imread(['..\images\test\binary_manual\',fname{ii}]);
end


Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties


Aggs_pcm = pp.pcm(Aggs);
tools.write_excel('data\Aggs_pcm.xlsx',Aggs_pcm);


Aggs_edm = pp.edm_sbs(Aggs);


% Aggs_kook = pp.kook(Imgs,1);


figure(1);
tools.plot_aggregates(Aggs_pcm);



