
% SEG_KMEANS6 Performs kmeans clustering on a modified feature set.
% Author:   Timothy Sipkens, 2020-08-13
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    seg_kmeans6(imgs,pixsizes)


%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs) % convert input images to a cell array
    Imgs = imgs;
    imgs = {Imgs.cropped};
    pixsizes = [Imgs.pixsize];
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
    disp('Subtracting background...');
    img = agg.bg_subtract(img); % background subtraction
    disp('Complete.');
    disp(' ');
    
    

    %== STEP 2: Pre-process image ========================================%
    %-- A: Perform denoising ---------------------------------------------%
    disp('Denoising...');
    img_denoise = imbilatfilt(img);
    % img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
    disp('Complete.');
    disp(' ');
    
    
    %-- B: Use texture in bottom hat images ------------------------------%
    disp('Computing texture layer...');
    se = strel('disk',20);
    img_both = imbothat(img_denoise,se);

    i10 = imbilatfilt(img_both); % denoise
    i11 = entropyfilt(i10, true(15)); % entropy filter, related to texture
    se12 = strel('disk', max(round(5*morph_param),1));
    i12 = imclose(i11, se12);
    i12 = im2uint8(i12 ./ max(max(i12)));
    disp('Complete.');
    disp(' ');


    %-- C: Perform multi-threshold ---------------------------------------%
    disp('Computing mutli-threshold layer...');
    i1 = im2uint8(img_denoise);
    i1 = imgaussfilt(i1,max(round(5*morph_param),1));

    lvl2 = graythresh(i1); % simple Otsu threshold
    i2a = ~im2bw(i1, lvl2); % Otsu binary
    
    % now, loop through threshold values above Otsu 
    % and find number of pixels that are part of the aggregates
    lvl3 = 1:0.002:1.25;
    n_in = ones(size(lvl3));
    for ll=1:length(lvl3)
        n_in(ll) = sum(sum(~im2bw(i1, lvl2 * lvl3(ll))));
    end
    n_in = movmean(n_in, 10); % apply moving average to smooth out curve, remove kinks
    p = polyfit(lvl3(1:10), n_in(1:10), 1); % fit linear curve to inital points
    n_in_pred = p(1).*lvl3 + p(2); % predicted values of number of pixels in aggregates
    lvl4 = find(((n_in - n_in_pred) ./ n_in_pred) > 0.10); % cases that devaite 10% from initial trend
    lvl4 = lvl3(lvl4(1)); % use the first case found in preceding line
    i2b = ~im2bw(i1, lvl2 * lvl4); % binary at a fraction above Otsu threshold

    se3 = strel('disk',max(round(5*morph_param),1));
    i3 = imclose(i2b,se3);
        % close the higher threshold image 
        % to remove noisy points now included in binary

    i5 = zeros(size(i2b));
    bw1 = bwlabel(i3);
    for jj=1:max(max(bw1))
        if any(i2a(bw1==jj)==1)
            i5(bw1==jj) = 1;
        end
    end
    i5 = imgaussfilt(im2uint8(i5.*255), 15);
    disp('Complete.');
    disp(' ');


    %-- Combine feature set ----------------------------------------------%
    feature_set{ii} = single(cat(3,...
        repmat(i12,[1,1,1]),...
        repmat(i5,[1,1,1]),...
        repmat(img_denoise,[1,1,1])...
        ));
    
    
    
    %== STEP 3: Perform kmeans segmentation ==============================%
    disp('Performing k-means...');
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
if n==1
    img_binary = img_binary{1};
    img_kmeans = img_kmeans{1};
    feature_set = feature_set{1};
end

    
end

