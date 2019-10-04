
clear;
close all;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
% imshow(Imgs(1).RawImage);
% colormap('gray');


%-- Run thresholding for all of the images -------------------------------%
[imgs_aggs,imgs_binary,Aggs] = ...
    thresholding_ui.perform_th(Imgs);
[Imgs.binary] = imgs_binary{:};


%-- Save images and labels to JPGs ------------------%
% for ii=1:length(Imgs)
%     imwrite(Imgs(ii).binary,['../train-labels/img_',Imgs(ii).fname(1:end-4),'.jpg']);
%     imwrite(Imgs(ii).cropped,['../train-images/img_',Imgs(ii).fname(1:end-4),'.jpg']);
% end


% [Aggs_manual,Data_manual] = ...
%     manual.perform_man(Aggs);


Aggs_pcm = pcm.perform_pcm(Aggs);


% Aggs_kook = kook.perform_kook(Imgs);


% Aggs_kook_mod = kook_mod.perform_km(Aggs);


% load('data\data_FlareNet.mat');
% data(1).dp(1) = dp;
% data(1).dp(2) = dp;
% fname = 'sample2.json'; % json file name
% tools.write_json(fname,data); % write formatted json file

