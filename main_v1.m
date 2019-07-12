
clear;
close all;
clc;

img_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
img = tools.get_imgs(img_ref); % load a single image
img = tools.get_footer_scale(img); % get footer for selected image
imshow(img.Cropped);


% disp('Performing PCM analysis...');
% pcm.evaluate(img_ref);
% disp('Complete.');
% disp(' ');


% disp('Performing original Kook analysis...');
% dp_kook = kook.evaluate(img_ref);
% disp('Complete.');
% disp(' ');


% disp('Performing modified Kook analysis...');
% kook_mod.evaluate(img_ref);
% disp('Complete.');
% disp(' ');



load('data\data_FlareNet.mat')
fname = 'sample2.json'; % json file name
tools.write_json(fname,data); % write formatted json file


