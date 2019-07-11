
clear;
close all;
clc;

% img_ref = tools.get_img_ref; % generates a set of images to be analyzed
% img_ref.RawImage = tools.get_img(img_ref);
% img_ref = tools.get_footer_scale(img_ref);
% imshow(img_ref.Cropped);


% disp('Performing PCM analysis...');
% pcm.perform(img_ref);
% disp('Complete.');
% disp(' ');


% disp('Performing original Kook analysis...');
% kook.perform(img_ref);
% disp('Complete.');
% disp(' ');


% disp('Performing modified Kook analysis...');
% kook_mod.perform(img_ref);
% disp('Complete.');
% disp(' ');



load('data\data_FlareNet.mat')
fname = 'sample2.json'; % json file name
tools.write_json(data,fname); % write formatted json file


