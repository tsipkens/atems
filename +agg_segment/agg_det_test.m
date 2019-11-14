
% AGG_DET_TEST A function for testing new aggregate segmentations.
% Author:   Timothy Sipkes, 2019-10-04
%=========================================================================%

function [img_binary] = ...
    agg_det_test(imgs,pixsize,minparticlesize,coeffs)


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
i2 = double(img)./max(max(double(img)));



%== Step 2: k-Means clustering ===========================================%
%-- Get rough mask using thresholding ------------------------------------%
feature_set = [];
for ss=4%1:1:12
    se = strel('disk',ss);
    if ss<0; num=3; else; num = 1; end
    img_morph = repmat(imclose(img,se),[1,1,num]);
    feature_set = cat(3,feature_set,img_morph);
end

feature_set = imbilatfilt(feature_set);

i3 = mean(double(feature_set),3)./max(max(mean(double(feature_set),3)));
level = 0.98.*mean(mean(i3));
bw = ~(i3<level);



%-- Perform kmeans segmentation ------------------------------------------%
% bw = imsegkmeans(feature_set,2,'NormalizeInput',true);
% bw = ~(bw==1);
% 
% [~,ind_min] = min([mean(img(bw)),mean(img(~bw))]);
% bw = bw==(ind_min-1);



img_bewBW = bw;



%== Step 3: Rolling ball transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);
%{
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
%}


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

img_binary = ~img_bewBW;

end

