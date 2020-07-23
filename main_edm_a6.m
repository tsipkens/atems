
clear;
close all;
clc;

listing = dir('..\images\A6\binary_manual\*.tif');

for ii=1:length(listing)
    imgs_binary{ii} = imread([listing(ii).folder,filesep,...
        listing(ii).name]);
end

[Aggs_edm,dp_bin,S,S_fit] = pp.edm_sbs(...
    imgs_binary,1/1.867.*ones(size(imgs_binary)));

