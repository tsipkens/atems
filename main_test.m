
clear;
clc;

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image
imgs = {Imgs.cropped};

%%
% [imgs_binary] = ...
%     agg_segment.agg_det_test(Imgs);
imgs_binary = {};
imgs_kmeans = {};
feature_set = {};
for ii=1:length(imgs)
    [imgs_binary{ii},imgs_kmeans{ii},feature_set{ii}] = ...
        agg_segment.agg_det_kmeans3(Imgs(ii));
end

figure(1);
tools.plot_binary_overlay(imgs{1},imgs_binary{1});

figure(2);
tools.plot_binary_overlay(imgs{1},imgs_kmeans{1});

figure(3);
montage(feature_set{1});

% figure(4);
% i10 = bwmorph(imgs_binary{1},'skel',inf);
% tools.plot_binary_overlay(imgs{1},i10);

figure(6);
imshow(imgs{1});

% for ii=1:length(imgs)
%     man = load('images/manual/imgs_binary.mat');
%     im_diff = man.imgs_binary{1}-imgs_binary{1};
%     added(ii) = sum(sum(im_diff==1))/sum(sum(man.imgs_binary{ii}==1));
%     missed(ii) = sum(sum(im_diff==-1))/sum(sum(man.imgs_binary{ii}==1));
%     perim_err(ii) = sum(sum(bwperim(imgs_binary{ii})))/...
%         sum(sum(man.imgs_binary{ii}==1));
% end
% 
% im_diff(im_diff==-1) = 2;
% opts.cmap = [0,1,0;1,0,0];
% opts.bool_outline = 0;
% tools.plot_binary_overlay(imgs{1},im_diff,opts);

figure(1);

% [Aggs,S,dp_bin] = pp.edm_sbs(imgs_binary{1},Imgs(1).pixsize);


