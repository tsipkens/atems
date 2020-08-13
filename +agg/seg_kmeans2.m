
% SEG_KMEANS2 Performs kmeans clustering on a modified feature set.
% Author:   Timothy Sipkens, 2019-11-19
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    seg_kmeans2(imgs,pixsize)


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


%== STEP 1: Attempt to the remove background gradient ====================%
img = agg.bg_subtract(img); % background subtraction

% disp('Performing background subtraction...');
% se_bg = strel('disk',80);	
% pre_bg = imclose(img,se_bg);	
% 
% [X,Y] = meshgrid(1:size(img,2), 1:size(img,1));	
% bg_fit = fit(double([X(:),Y(:)]), double(pre_bg(:)), 'poly22');	
% bg = uint8(round(bg_fit(X,Y)));	
% 
% t0 = double(max(max(bg))-bg);	
% t1 = double(img)+t0;	
% t2 = t1-min(min(t1));	
% img = uint8(round(255.*t2./max(max(t2))));	
% disp('Complete.');	
% disp(' ');



%== STEP 2: Pre-process image ============================================%
%-- A: Perform denoising --------------------------------------------------%
disp('Performing denoising...');
img_denoise = imbilatfilt(img);
% img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
disp('Complete.');
disp(' ');


%-- B: Get rough mask using thresholding ---------------------------------%
lvl = graythresh(img); % Otsu thresholding
bw_thresh = 255.*(~imbinarize(img,lvl));

se = strel('disk',round(30*morph_param));
bw_thresh2 = imclose(bw_thresh,se);
    % attains rough estimates of particle boundaries


%-- C: Use texture in bottom hat images ----------------------------------%
se = strel('disk',20);
img_both = imbothat(img_denoise,se);

i10 = imbilatfilt(img_both,1e20);
i11 = entropyfilt(i10,true(15));
se12 = strel('disk',max(round(5*morph_param),1));
i12 = imclose(i11,se12);
i12 = uint8(i12./max(max(i12)).*255);


%-- D: Perform multi-thresholding ----------------------------------------%
i1 = double(img_denoise);
i1 = i1./max(max(i1));
i1 = imgaussfilt(i1,max(round(5*morph_param),1));

lvl2 = graythresh(i1); % simple threshold
i2b = ~im2bw(i1,lvl2);
i2 = ~im2bw(i1,lvl2*1.15);

se3 = strel('disk',max(round(5*morph_param),1));
i3 = imclose(i2,se3);

i5 = zeros(size(i2));
bw1 = bwlabel(i3);
for ii=1:max(max(bw1))
    if any(i2b(bw1==ii)==1)
        i5(bw1==ii) = 1;
    end
end
i5 = uint8(i5.*255);


%-- Combine feature set --------------------------------------------------%
feature_set = single(cat(3,...
    repmat(bw_thresh2,[1,1,1]),... % aggregates disappear if too large
    repmat(img_denoise,[1,1,1]),... % increases the interconnectedness (w/ bot. and tophat)
    repmat(i5,[1,1,1]),...
    repmat(i12,[1,1,1])...
    ));

% weights = [3,6,2,8];
% for kk=1:size(feature_set,3)
%     t0 = feature_set(:,:,kk);
%     t0 = t0(:); % linearize
%     t0 = t0-mean(t0);
%     t0 = t0./var(t0) .* weights(kk)./max(weights);
%     feature_set(:,:,kk) = reshape(t0,size(feature_set,1:2));
% end



%== STEP 3: Perform kmeans segmentation ==================================%
disp('Performing k-means clustering...');
bw = imsegkmeans(feature_set,2);
disp('Complete.');
disp(' ');
bw = bw==1;

[~,ind_max] = max([mean(img_denoise(bw)),mean(img_denoise(~bw))]);
img_kmeans = bw==(ind_max-1);



%== STEP 4: Rolling Ball Transformation ==================================%
% img_binary = ~agg.rolling_ball(...
%     ~img_kmeans,pixsize,minparticlesize,coeffs);

ds = round(6*morph_param);
se6 = strel('disk',max(ds,2));
    % disk size limited by size of holes in particle
i7 = imclose(img_kmeans,se6);

se7 = strel('disk',max(ds-1,1));
    % disk size must be less than se6 to maintain connectivity
img_rb = imopen(i7,se7);

img_binary = bwareaopen(img_rb,3); % remove particles below 3 pixels

end

