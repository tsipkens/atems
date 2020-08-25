
% MAIN_CROP  A simple script to crop the footer out of images and save the result.
% Requires that TEM images footer is white (specifically an entire row at the top is white). 
% T. Sipkens, 2020-06-23
%=========================================================================%

clear;
close all; fclose all;
clc;

fd = '..\data\2018-carleton\';
case_name = 'RUKM1_C9';

fd = [fd,'images\',case_name,'\'];
data = dir([fd,'*.tif']);
for ii=length(data):-1:1
    Imgs(ii).fname = data(ii).name;
    Imgs(ii).dir = [data(ii).folder,'\'];
end

Imgs = tools.load_imgs(Imgs); % load actual image data
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped};

%{
fold_name = replace(Imgs_ref.folder, '\images\', '\cropped[ts]\');
status = mkdir(fold_name);


tools.write_images(imgs,{Imgs.fname},fold_name);
%}