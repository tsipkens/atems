
% AGG_DET_HOUGH  Hough Transformation and Rolling Ball Transformation
%                Automatic detection of the aggregates on TEM images
% Authors:  Ramin Dastanpour & Steven N. Rogak
% Notes:    Developed at the University of British Columbia
%           Last updated in Feb. 2016
%=========================================================================%

function [img_binary] = ...
    agg_det_hough(img,pixsize,minparticlesize,coeffs,bool_plot) 

if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end


%== Step 1: Apply intensity threshold ====================================%
level = graythresh(img);
bw = imbinarize(img,level);

bw = ~imclearborder(~bw); % clear aggregates on border



%== Step 2: Rolling Ball Transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);

disp('Morphologically closing image...');
se = strel('disk',round(a*minparticlesize/pixsize));
img_bewBW = imclose(bw,se);
if bool_plot; subplot(3,3,4); imshow(img_bewBW); end

disp('Morphologically opening image...');
se = strel('disk',round(b*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW,se);
if bool_plot; subplot(3,3,5); imshow(img_bewBW); end

disp('Morphologically closing image...');
se = strel('disk',round(c*minparticlesize/pixsize));
img_bewBW = imclose(img_bewBW,se);
if bool_plot; subplot(3,3,6); imshow(img_bewBW); end

disp('Morphologically opening image...');
se = strel('disk',round(d*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW,se);
if bool_plot; subplot(3,3,7); imshow(img_bewBW); end
disp('Completed morphological operations.');


%== Step 3: Delete blobs under a threshold area size =====================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
if nparts>50 % if a lot of particles, remove more particles
    mod = 10;
    disp(['Found too many particles, removing particles below: ',...
        num2str(e*mod),' nm.']);
else
    mod = 1;
end
    
for kk = 1:nparts
    area = length(CC.PixelIdxList{1,kk})*pixsize^2;
    
    if area <= (mod*e*minparticlesize/pixsize)^2
        img_bewBW(CC.PixelIdxList{1,kk}) = 1;
    end
end
if bool_plot; subplot(3,3,8); imshow(img_bewBW); end

h = figure(gcf);
tools.plot_binary_overlay(img,img_bewBW);
f = gcf;
f.WindowState = 'maximized'; % maximize figure

img_binary = img_bewBW;

end
