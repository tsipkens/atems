
clear;
close all;
clc;

img_ref = tools.get_img_ref; % generates a set of images to be analyzed
img = tools.get_img(img_ref);

disp('Performing PCM analysis...');
pcm.perform(img_ref);
disp('Complete.');
disp(' ');


% disp('Performing original Kook analysis...');
% kook.perform(img_ref);
% disp('Complete.');
% disp(' ');


% disp('Performing modified Kook analysis...');
% kook_mod.perform(img_ref);
% disp('Complete.');
% disp(' ');






