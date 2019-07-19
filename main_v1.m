
clear;
close all;
clc;

img_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
imgs = tools.get_imgs(img_ref); % load a single image
imgs = tools.get_footer_scale(imgs); % get footer for selected image
% imshow(imgs(1).RawImage);
% colormap('gray');



% disp('Performing manual analysis...');
% Agg_manual = manual.evaluate(imgs);
% disp('Complete.');
% disp(' ');


% disp('Performing PCM analysis...');
% Agg_pcm = pcm.evaluate(imgs);
% disp('Complete.');
% disp(' ');


% disp('Performing original Kook analysis...');
% Agg_kook = kook.evaluate(imgs);
% disp('Complete.');
% disp(' ');


disp('Performing modified Kook analysis...');
Agg_kook_mod = kook_mod.evaluate(imgs);
disp('Complete.');
disp(' ');


% load('data\data_FlareNet.mat');
% data(1).dp(1) = dp;
% data(1).dp(2) = dp;
% fname = 'sample2.json'; % json file name
% tools.write_json(fname,data); % write formatted json file

