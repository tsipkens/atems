
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
Aggs = thresholding_ui.evaluate_th(Imgs);


% disp('Performing manual analysis...');
% Aggs_manual = manual.evaluate_man(Aggs);
% disp('Complete.');
% disp(' ');


% disp('Performing PCM analysis...');
% Aggs_pcm = pcm.evaluate_pcm(Aggs);
% disp('Complete.');
% disp(' ');


% disp('Performing original Kook analysis...');
% Aggs_kook = kook.evaluate_kook(imgs);
% disp('Complete.');
% disp(' ');


disp('Performing modified Kook analysis...');
Aggs_kook_mod = kook_mod.evaluate_km(Aggs);
disp('Complete.');
disp(' ');


% load('data\data_FlareNet.mat');
% data(1).dp(1) = dp;
% data(1).dp(2) = dp;
% fname = 'sample2.json'; % json file name
% tools.write_json(fname,data); % write formatted json file

