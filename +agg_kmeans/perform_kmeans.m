
% PERFORM_KMEANS A function to perform kmeans clustering on an aggregate image
% Author:   Timothy Sipkes
% Date:     October 4, 2019

function [img_binary] = perform_kmeans(imgs,pixsize,fname))


%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
    fname = {Imgs_str.fname};
elseif ~iscell(imgs)
    imgs = {imgs};
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end
%-------------------------------------------------------------------------%


img = imgs{1};

[X,Y] = meshgrid(1:size(img,2),1:size(img,1));
bg_fit = fit([X(:),Y(:)],img(:),'poly11');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(img)+t0;
t2 = t1-min(min(t1));
img = uint8(round(255.*t2./max(max(t2))));


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



%== Step 2: Remove aggregates touching the edge of the image =============%
bw = ~imclearborder(~bw); % clear aggregates on border


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

img_binary = img_bewBW;


end

