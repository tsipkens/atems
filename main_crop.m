
% MAIN_CROP  A simple script to crop the footer out of images and save the result.
% T. Sipkens, 2020-06-23
%=========================================================================%

clear;
close all; fclose all;
clc;

fd = '..\data\2018-carleton\';
case_name = 'RUKM1_C9';

Imgs_ref.dir = [fd,'images\',case_name,'\'];
Imgs_ref.data = dir([Imgs_ref.dir,'*.tif']);
Imgs_ref.fname = {Imgs_ref.data.name};

Imgs = tools.get_imgs(Imgs_ref); % load actual image data
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image


imgs = {Imgs.cropped};


fold_name = replace(Imgs_ref.dir, '\images\', '\cropped[ts]\');
status = mkdir(fold_name);


tools.write_images(imgs,{Imgs.fname},fold_name);

