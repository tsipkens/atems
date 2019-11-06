
% AGG_DET_OTSU_RB  Otsu thresholding and rolling ball transformation
%                  for automatic detection of the aggregates on TEM images
% Authors:  Ramin Dastanpour, Steven N. Rogak, 2016-02
% Modified: Timothy Sipkens
% Notes:    Developed at the University of British Columbia
%=========================================================================%

function [img_binary] = ...
    agg_det_otsu_rb(imgs,pixsize,minparticlesize,coeffs,bool_plot) 

%== Parse inputs =========================================================%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end
img = imgs{1}; % currently only operated on first image

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(img)); end

if ~exist('minparticlesize','var'); minparticlesize = []; end
if isempty(minparticlesize); minparticlesize = 4.9; end

if ~exist('coeffs','var'); coeffs = []; end
if isempty(coeffs)
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
        % coefficients for automatic Hough transformation
    if pixsize <= 0.181
        coeffs = coeff_matrix(1,:);
    elseif pixsize <= 0.361
        coeffs = coeff_matrix(2,:);
    else 
        coeffs = coeff_matrix(3,:);
    end
end

if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end
%-------------------------------------------------------------------------%



%== Step 1: Apply intensity threshold (Otsu) =============================%
level = graythresh(img); % applies Otsu thresholding
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


%-- Plot results ---------------------------------------------------------%
if bool_plot; subplot(3,3,8); imshow(img_bewBW); end

h = figure(gcf);
tools.plot_binary_overlay(img,img_bewBW);
f = gcf;
f.WindowState = 'maximized'; % maximize figure

img_binary = img_bewBW;

end
