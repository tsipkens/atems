
clear;
close all;
clc;

% Imgs = tools.load_imgs; % OPTION 1: load a single image
% load('temp/b/Imgs.mat'); % OPTION 2: load preset Imgs
Imgs = tools.load_imgs('images'); Imgs(end) = []; % OPTION 3: load all images in 'images' folder

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};
