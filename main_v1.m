
clear;
close all;
clc;

img = tools.get_img; % generates a set of images to be analyzed


disp('Performing PCM analysis...');
PCM.perform(img);
disp('Complete.');
disp(' ');


disp('Performing original Kook analysis...');
kook_orig.perform(img);
disp('Complete.');
disp(' ');


disp('Performing modified Kook analysis...');
kook.perform(img);
disp('Complete.');
disp(' ');






