
% MAIN_CROP  A simple script to crop the footer out of images and save the result.
% T. Sipkens, 2020-06-23
%=========================================================================%

clear;
close all;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load actual image data
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image


imgs = {Imgs.cropped};


fold_name = replace(Imgs_ref.dir, 'pooyan\images', 'pooyan\cropped[ts]');
status = mkdir(fold_name);


tools.write_images(imgs,{Imgs.fname},fold_name);

