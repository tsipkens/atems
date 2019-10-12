
% AGG_DET_KMEANS A function to perform kmeans clustering on an aggregate image
% Author:   Timothy Sipkes, 2019-10-04
%=========================================================================%

function [img_binary] = ...
    agg_det_kmeans(imgs,pixsize,minparticlesize,coeffs)


%== Parse inputs =========================================================%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

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
%-------------------------------------------------------------------------%


img = imgs{1};



%== Step 1: Attempt to the remove background gradient ====================%
[X,Y] = meshgrid(1:size(img,2),1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]),double(img(:)),'poly11');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(img)+t0;
t2 = t1-min(min(t1));
img = uint8(round(255.*t2./max(max(t2))));



%== Step 2: k-Means clustering ===========================================%
%-- Get rough mask using thresholding ------------------------------------%
level = graythresh(img);
bw_thresh = 255.*imbinarize(img,level);

se = strel('disk',40);
bw_thresh2 = imopen(bw_thresh,se);


%-- Perform total variation denoising ------------------------------------%
N = size(img);
mu = 15;
disp('Performing total var. denoising...');
img_atv = reshape(...
    tools.tot_var_SB_ATV(double(img(:)),mu,N),N);
img_atv = uint8(img_atv);
disp('Complete.');
disp(' ');
% increases the interconnectedness when
%   combined with bottom hat and top hat


%-- Use morphological operations to improve kmeans -----------------------%
se = strel('disk',20);
img_bh = imbothat(img_atv,se);
img_th = imtophat(img_atv,se);
featureSet = cat(3,...
    repmat(bw_thresh2,[1,1,3]),... % aggregates disappear if too large
    repmat(img_bh,[1,1,3]),...
    repmat(img_th,[1,1,3]),... % expands aggregate slightly
    repmat(img_atv,[1,1,3]),...
    repmat(255-img_atv,[1,1,3]),...
    repmat(img,[1,1,0]),... % decreases interconnectedness
    repmat(255-img,[1,1,0])...
    ); % img2


%-- Perform kmeans segmentation ------------------------------------------%
bw = imsegkmeans(featureSet,2,'NormalizeInput',true);
bw = ~(bw==1);

[~,ind_min] = min([mean(img_atv(bw)),mean(img_atv(~bw))]);
bw = bw==(ind_min-1);



%== Step 3: Rolling ball transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);

disp('Morphologically closing image...');
se = strel('disk',round(a*minparticlesize/pixsize));
img_bewBW1 = imclose(bw,se);

disp('Morphologically opening image...');
se = strel('disk',round(b*minparticlesize/pixsize));
img_bewBW2 = imopen(img_bewBW1,se);

disp('Morphologically closing image...');
se = strel('disk',round(c*minparticlesize/pixsize));
img_bewBW3 = imclose(img_bewBW2,se);

disp('Morphologically opening image...');
se = strel('disk',round(d*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW3,se);
disp('Completed morphological operations.');



%== Step 3: Delete blobs under a threshold area size =====================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
if nparts>40 % if a lot of particles, remove more particles
    mod = minparticlesize/2;
    disp(['Found too many particles, removing particles below: ',...
        num2str(mod),' nm.']);
else
    mod = 1;
end

for kk = 1:nparts
    area = length(CC.PixelIdxList{1,kk})*pixsize^2;
    
    if area <= (mod*e*minparticlesize/pixsize)^2
        img_bewBW(CC.PixelIdxList{1,kk}) = 1;
    end
end

img_binary = img_bewBW;


end

