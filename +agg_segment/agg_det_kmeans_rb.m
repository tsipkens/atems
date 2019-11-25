
% AGG_DET_KMEANS_RB Performs kmeans clustering + a rolling ball transformation.
% Author:   Timothy Sipkens, 2019-10-04
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    agg_det_kmeans_rb(imgs,pixsize,minparticlesize,coeffs)


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
if isempty(pixsize); pixsize = ones(size(imgs)); end

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end
%=========================================================================%



%== STEP 1: Attempt to the remove background gradient ====================%
[X,Y] = meshgrid(1:size(img,2),1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]),double(img(:)),'poly11');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(img)+t0;
t2 = t1-min(min(t1));
img = uint8(round(255.*t2./max(max(t2))));



%== STEP 2: Pre-process image ============================================%
%-- Get rough mask using thresholding ------------------------------------%
level = graythresh(img); % Otsu thresholding
bw_thresh = 255.*imbinarize(img,level);

se = strel('disk',40);
bw_thresh2 = imopen(bw_thresh,se);
    % attains rough estimates of particle boundaries

%-- Perform denoising ----------------------------------------------------%
disp('Performing denoising...');
img_denoise = imbilatfilt(img);
% img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
disp('Complete.');
disp(' ');

%-- Use morphological operations to improve kmeans -----------------------%
se = strel('disk',20);
img_both = imbothat(img_denoise,se);
img_toph = imtophat(img_denoise,se);

%-- Perform multi-thresholding -------------------------------------------%
i1 = img_denoise;
i1 = imgaussfilt(i1,5);

lvl = graythresh(i1);
i2b = ~im2bw(i1,lvl);
i2 = ~im2bw(i1,lvl*1.15);

se3 = strel('disk',4);
i3 = imclose(i2,se3);

i5 = zeros(size(i2));
bw1 = bwlabel(i3);
for ii=1:max(max(bw1))
    if any(i2b(bw1==ii)==1)
        i5(bw1==ii) = 1;
    end
end

%-- Combine feature set --------------------------------------------------%
feature_set = cat(3,...
    repmat(bw_thresh2,[1,1,3]),... % aggregates disappear if too large
    repmat(img_both,[1,1,3]),...
    repmat(img_toph,[1,1,3]),... % expands aggregate slightly
    repmat(img_denoise,[1,1,3]),... % increases the interconnectedness (w/ bot. and tophat)
    repmat(255-img_denoise,[1,1,3]),...
    repmat(img,[1,1,0]),... % decreases interconnectedness
    repmat(255-img,[1,1,0]),...
    repmat(i5,[1,1,0])...
    ); % img2



%== STEP 3: Perform kmeans segmentation ==================================%
disp('Performing k-means clustering...');
bw = imsegkmeans(feature_set,2,'NormalizeInput',true);
disp('Complete.');
disp(' ');
bw = ~(bw==1);

[~,ind_min] = min([mean(img_denoise(bw)),mean(img_denoise(~bw))]);
img_kmeans = ~(bw==(ind_min-1));



%== STEP 4: Rolling Ball Transformation ==================================%
img_binary = ~agg_segment.rolling_ball(~img_kmeans,pixsize,minparticlesize,coeffs);

% i6 = ~bw;
% 
% se6 = strel('disk',10);
% i7 = imclose(i6,se6);
% img_binary = imopen(i7,se3);

end

