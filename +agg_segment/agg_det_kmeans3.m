
% AGG_DET_KMEANS3 Performs kmeans clustering on a modified feature set.
% Author:   Timothy Sipkens, 2019-11-19
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    agg_det_kmeans3(imgs,pixsize)


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
%=========================================================================%

morph_param = 0.8/pixsize
img_orig = img;


%== STEP 1: Attempt to the remove background gradient ====================%
img = agg_segment.bg_subtract(img);
img = imadjust(img);


%== STEP 2: Pre-process image ============================================%
%-- A: Perform denoising --------------------------------------------------%
disp('Performing denoising...');
% img_denoise = imbilatfilt(img,1e20);
img_denoise = tools.imtotvar_sb_atv(img,30); % alternate total variation denoise
disp('Complete.');
disp(' ');

img = img_denoise;

%-- B: Get rough mask using thresholding ---------------------------------%
lvl = graythresh(img); % Otsu thresholding
bw_thresh = ~imbinarize(img,lvl*1.2);
bw_thresh1 = double(bwareaopen(bw_thresh,300));

se = strel('disk',round(15*morph_param),8);
bw_thresh2 = imclose(bw_thresh1,se);
    % attains rough estimates of particle boundaries
lvl3 = graythresh(img)*1.1;
bw_thresh3 = imbinarize(bw_thresh2,lvl3);
bw_thresh2 = uint8(bw_thresh2.*255);


%-- C: Use texture in bottom hat images ----------------------------------%
% se = strel('disk',round(20*morph_param),8);

% img_both = imbothat(img,se);
% i10 = imbilatfilt(img_both,1e20);
% i11 = entropyfilt(i10,true(round(15*morph_param/2)*2-1));
% i11 = i11./max(max(i11));
% se12 = strel('disk',max(round(5*morph_param),1));
% i12 = imclose(imopen(i11,se12),se12);
% i12 = uint8(i12./max(max(i12)).*255);

i12 = entropyfilt(img,true(round(10*morph_param/2)*2-1));
i12 = uint8(i12./max(max(i12)).*255);
se13 = strel('disk',round(7*morph_param),8);
i13 = imopen(i12,se13);


%-- D: Perform multi-thresholding ----------------------------------------%
i1 = double(img);
i1 = i1./max(max(i1));
i1 = imgaussfilt(i1,max(round(5*morph_param),1));

lvl2 = graythresh(i1);
i2b = ~im2bw(i1,lvl2);
i2 = ~im2bw(i1,lvl2*1.05);

se3 = strel('disk',max(round(7*morph_param),1));
i3 = imopen(imclose(i2,se3),se3);
i4 = or(i3,bw_thresh3).*255;


%-- Combine feature set --------------------------------------------------%
feature_set = cat(3,...
    repmat(bw_thresh2,[1,1,1]),... % aggregates disappear if too large
    repmat(255-img,[1,1,4]),... % increases the interconnectedness (w/ bot. and tophat)
    repmat(i4,[1,1,0]),...
    repmat(i13,[1,1,6])...
    );



%== STEP 3: Perform kmeans segmentation ==================================%
disp('Performing k-means clustering...');
bw = imsegkmeans(feature_set,2,'NormalizeInput',true);
disp('Complete.');
disp(' ');
bw = bw==1;

[~,ind_max] = max([mean(img(bw)),mean(img(~bw))]);
img_kmeans = bw==(ind_max-1);



%== STEP 4: Rolling Ball Transformation ==================================%
% img_binary = ~agg_segment.rolling_ball(...
%     ~img_kmeans,pixsize,minparticlesize,coeffs);

ds = round(6*morph_param);
se6 = strel('disk',max(ds,2));
    % disk size limited by size of holes in particle
i7 = imclose(img_kmeans,se6);

se7 = strel('disk',max(ds-2,1));
    % disk size must be less than se6 to maintain connectivity
img_rb = imopen(i7,se7);

img_binary = bwareaopen(img_rb,30); % remove particles below 30 pixels

end

