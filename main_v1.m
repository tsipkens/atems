
clear;
close all;
clc;

img = tools.get_img; % generates a set of images to be analyzed


disp('Performing PCM analysis...');
PCM.perform(img);
disp('Complete.');
disp(' ');


disp('Performing Kook analysis...');
kook.perform(img);
disp('Complete.');
disp(' ');






