

clear;
close all;
clc;

Imgs_ref = tools.get_img_ref; % get location of files
% load('result/test_img_ref.mat');
    % load a reference to a set of images to be analyzed

Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

imgs = {Imgs.cropped}; % copy variables locally
pixsize = [Imgs.pixsize];
fname = {Imgs.fname};


%-- Run thresholding for all of the images -------------------------------%
% opts.bool_kmeans = 1;
% opts.bool_otsu = 0;
% imgs_binary = agg.multi_seg(imgs,pixsize,opts);
% [Imgs.binary] = imgs_binary{:};

for ii=1:length(imgs) % loop through images and apply k-means
    disp(['[ IMAGE ',num2str(ii), ' OF ', ...
        num2str(length(imgs)), ...
        ' ============================]']);
    imgs_binary{ii} = archive.seg_kmeans6(imgs{ii},pixsize(ii));
end
disp('[ Complete. ==============================]');
disp(' ');


% for ii=1:length(Imgs)
%     imgs_binary{ii} = ...
%         imread(['..\images\test\binary_manual\',fname{ii}]);
% end

figure(3);
Aggs = agg.analyze_binary(...
    imgs_binary,imgs,pixsize,fname);
        % determine aggregate properties

tools.write_images(imgs_binary,fname,'temp\a');

