
clear;
close all;
clc;

img_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(img_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
% imshow(imgs(1).RawImage);
% colormap('gray');


%-- Run thresholding for all of the images -------------------------------%
Aggs = thresholding_ui.perform_th(Imgs);


[Aggs_manual,Data_manual] = manual.perform_man(Aggs);


% Aggs_pcm = pcm.perform_pcm(Aggs);


% Aggs_kook = kook.perform_kook(Imgs);


% Aggs_kook_mod = kook_mod.perform_km(Aggs);


% load('data\data_FlareNet.mat');
% data(1).dp(1) = dp;
% data(1).dp(2) = dp;
% fname = 'sample2.json'; % json file name
% tools.write_json(fname,data); % write formatted json file

