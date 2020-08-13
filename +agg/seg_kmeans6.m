
% SEG_KMEANS6 Performs kmeans clustering on a modified feature set.
% Author:   Timothy Sipkens, 2020-08-13
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    seg_kmeans6(imgs,pixsizes)


%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs) % convert input images to a cell array
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsizes = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

n = length(imgs); % number of images to consider

if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = ones(size(imgs)); end
if length(pixsizes)==1; pixsizes = pixsizes .* ones(size(imgs)); end % extend if scalar
%-------------------------------------------------------------------------%

% Loop over images, calling seg function below on each iteration.
img_binary{n} = []; % pre-allocate cells
img_kmeans{n} = [];
feature_set{n} = [];
for ii=1:n
    if n>1 % if more than one image, output text indicating image number
        disp(['[== IMAGE ',num2str(ii), ' OF ', ...
            num2str(length(imgs)), ' ============================]']);
    end
    
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
    
%== CORE FUNCTION ========================================================%
    morph_param = 0.8/pixsize

    %== STEP 1: Attempt to the remove background gradient ================%
    img = agg.bg_subtract(img); % background subtraction


    %== STEP 2: Pre-process image ========================================%
    %-- A: Perform denoising ---------------------------------------------%
    disp('Performing denoising...');
    img_denoise = imbilatfilt(img);
    % img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
    disp('Complete.');
    disp(' ');


    %-- B: Get rough mask using thresholding -----------------------------%
    %   Applied to original (not denoised) image.
    lvl = graythresh(img); % Otsu thresholding
    bw_thresh = 255.*(~imbinarize(img, lvl));

    % Apply morphological closing to combine small, close objects to
    % to attain rough estimates of particle boundaries
    % and remove really small objects.
    se = strel('disk', round(10*morph_param));
    bw_thresh2 = imclose(bw_thresh, se);

    % Blur edges using Gaussian filter 
    % to accommodate for some uncertainty in binary edges.
    i20 = imgaussfilt(im2uint8(bw_thresh2.*255), 10);


    %-- C: Use texture in bottom hat images ------------------------------%
    se = strel('disk',20);
    img_both = imbothat(img_denoise,se);

    i10 = imbilatfilt(img_both); % denoise
    i11 = entropyfilt(i10, true(15));
    se12 = strel('disk', max(round(5*morph_param),1));
    i12 = imclose(i11, se12);
    i12 = im2uint8(i12 ./ max(max(i12)));


    %-- D: Perform multi-thresholding ------------------------------------%
    i1 = im2uint8(img_denoise);
    i1 = imgaussfilt(i1,max(round(5*morph_param),1));

    lvl2 = graythresh(i1); % simple threshold
    i2b = ~im2bw(i1,lvl2);
    i2 = ~im2bw(i1,lvl2*1.15);

    se3 = strel('disk',max(round(5*morph_param),1));
    i3 = imclose(i2,se3);

    i5 = zeros(size(i2));
    bw1 = bwlabel(i3);
    for jj=1:max(max(bw1))
        if any(i2b(bw1==jj)==1)
            i5(bw1==jj) = 1;
        end
    end
    i5 = imgaussfilt(im2uint8(i5.*255), 10);


    %-- Combine feature set ----------------------------------------------%
    feature_set{ii} = single(cat(3,...
        ... repmat(i20,[1,1,1]),... % aggregates disappear if too large
        repmat(img_denoise,[1,1,1]),... % increases the interconnectedness (w/ bot. and tophat)
        repmat(i5,[1,1,1]),...
        repmat(i12,[1,1,1])...
        ));


    %== STEP 3: Perform kmeans segmentation ==============================%
    disp('Performing k-means clustering...');
    bw = imsegkmeans(feature_set{ii}, 2);
    disp('Complete.');
    disp(' ');
    bw = bw==1;

    [~,ind_max] = max([mean(img_denoise(bw)),mean(img_denoise(~bw))]);
    img_kmeans{ii} = bw==(ind_max-1);



    %== STEP 4: Rolling Ball Transformation ==============================%
    % img_binary = ~agg.rolling_ball(...
    %     ~img_kmeans,pixsize,minparticlesize,coeffs);

    ds = round(6 * morph_param);
    se6 = strel('disk', max(ds,2));
        % disk size limited by size of holes in particle
    i7 = imclose(img_kmeans{ii}, se6);

    se7 = strel('disk', max(ds-1,1));
        % disk size must be less than se6 to maintain connectivity
    img_rb = imopen(i7, se7);
    
    img_binary{ii} = bwareaopen(img_rb, 3); % remove particles below 3 pixels
%=========================================================================%
    
    
    if n>1 % if more than one image, output text
        disp('[== Complete. ==============================]');
        disp(' ');
        disp(' ');
    end
end

% If a single image, cell arrays are unnecessary.
% Extract and just output images. 
if length(imgs)==1
    img_binary = img_binary{1};
    img_kmeans = img_kmeans{1};
    feature_set = feature_set{1};
end

    
end

