
% SEG_KMEANS  Performs kmeans clustering on a modified feature set.
%   Uses the technique described in Sipkens and Rogak (Submitted) 
%   to segment soot aggregates in TEM images. This requires that image 
%   annotations / footer information be removed.
% Author: Timothy Sipkens, 2020-08-13
% Version: 6
% 
%-------------------------------------------------------------------------%
% Inputs: 
%   imgs      A cell array of images OR a single image.
%   pixsizes  The size of a pixel in nm/px, either as a scalar value for 
%             all of the images OR a vector with one entry per image.
%             If not given, assumed to be 1 nm/px, with implications for
%             the rolling ball transform.
% 
% Outputs:
%   img_binary  A cell array of binary / classified images, where 1
%               indicates particles and 0 indicates background.
%   img_kmeans  The k-means classified image, prior to apply the rolling
%               ball transform. 
%   feature_set Colour-equivalent images of the feature set used as
%               input to the k-means classifier.
%-------------------------------------------------------------------------%
%
%=========================================================================%

function [img_binary,img_kmeans,feature_set] = ...
    seg_kmeans(imgs,pixsizes)


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

tools.textheader('k-means');

% Loop over images, calling seg function below on each iteration.
img_binary{n} = []; % pre-allocate cells
img_kmeans{n} = [];
feature_set{n} = [];

disp('Segmenting images:'); tools.textbar([0, n]);
for ii=1:n
    
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
    
%== CORE FUNCTION ========================================================%
    morph_param = 0.8/pixsize; % parameter used to adjust morphological operations
    
    
    %== STEP 1: Attempt to the remove background gradient ================%
    img = agg.bg_subtract(img); % background subtraction
    tools.textbar([(ii-1)+0.45, n]);
    
    
    
    %== STEP 2: Pre-process image ========================================%
    %-- A: Perform denoising ---------------------------------------------%
    img_denoise = imbilatfilt(img);
    % img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
    tools.textbar([(ii-1)+0.49, n]); % partial textbar update
    
    
    
    %-- B: Use texture in bottom hat images ------------------------------%
    se = strel('disk',20);
    i10 = imbothat(img_denoise,se);

    % i10 = imbilatfilt(img_denoise); % denoise, aids in correctly identifying edges below
    i11 = entropyfilt(i10, true(15)); % entropy filter, related to texture
    se12 = strel('disk', max(round(5*morph_param),1));
    i12 = imclose(i11, se12);
    i12 = im2uint8(i12 ./ max(max(i12)));
    
    tools.textbar([(ii-1)+0.7, n]); % partial textbar update
    
    
    
    %-- C: Perform adjusted threshold ------------------------------------%
    i1 = im2uint8(img_denoise);
    i1 = imgaussfilt(i1,max(round(5*morph_param),1));

    lvl2 = graythresh(i1); % simple Otsu threshold
    i2a = ~im2bw(i1, lvl2); % Otsu binary
    
    % Now, loop through threshold values above Otsu 
    % and find number of pixels that are part of the aggregates.
    lvl3 = 1:0.002:1.25;
    n_in = ones(size(lvl3));
    for ll=1:length(lvl3) % loop, increasing the threshold level
        n_in(ll) = sum(sum(~im2bw(i1, min(lvl2 * lvl3(ll), 1))));
            % min(*, 1) prevents loop from going above max. brightness
    end
    n_in = movmean(n_in, 10); % apply moving average to smooth out curve, remove kinks
    p = polyfit(lvl3(1:10), n_in(1:10), 1); % fit linear curve to inital points
    n_in_pred = p(1).*lvl3 + p(2); % predicted values of number of pixels in aggregates
    lvl4 = find(((n_in - n_in_pred) ./ n_in_pred) > 0.10); % cases that devaite 10% from initial trend
    
    % If nothing found, revert to Otsu.
    if isempty(lvl4)
        lvl4 = 1;
        warning('Adjusted threshold failed. Using Otsu.');
        if n>1; tools.textbar([0, n]); tools.textbar([ii-1, n]); end
    end
    
    lvl4 = lvl3(lvl4(1)); % use the first case found in preceding line
    i2b = ~im2bw(i1, lvl2 * lvl4); % binary at a fraction above Otsu threshold
    
    % Close the higher threshold image 
    % to remove noisy points now included in binary.
    se3 = strel('disk',max(round(5*morph_param),1));
    i3 = imclose(i2b,se3);
        
    % Check if regions originally included in the Otsu threshold
    % (i) belong to an aggregate that remains in the newly thresholded
    % image and (ii) are not included in the new threshold image. 
    % If this is the case, add the pixels back. 
    i5 = zeros(size(i2b));
    bw1 = bwlabel(i3);
    for jj=1:max(max(bw1))
        if any(i2a(bw1==jj)==1)
            i5(bw1==jj) = 1; % add Otsu pixels back
        end
    end
    i5 = imgaussfilt(im2uint8(i5.*255), 15);
    
    tools.textbar([(ii-1)+0.82, n]); % partial textbar update
    
    

    %-- Combine feature set ----------------------------------------------%
    feature_set{ii} = single(cat(3,...
        repmat(i12,[1,1,1]),...
        repmat(i5,[1,1,1]),...
        repmat(img_denoise,[1,1,1])...
        ));
    
    
    
    
    %== STEP 3: Perform kmeans segmentation ==============================%
    bw = imsegkmeans(feature_set{ii}, 2);
    bw = bw==1;

    [~,ind_max] = max([mean(img_denoise(bw)),mean(img_denoise(~bw))]);
    img_kmeans{ii} = bw==(ind_max-1);
    
    tools.textbar([(ii-1)+0.99, n]); % partial textbar update
    
    
    
    %== STEP 4: Rolling Ball Transformation ==============================%
    ds = round(4 * morph_param);
    se6 = strel('disk', max(ds, 1));
        % disk size limited by size of holes in particle
    i7 = imclose(img_kmeans{ii}, se6);

    se7 = strel('disk', max(ds-1, 0));
        % disk size must be less than se6 to maintain connectivity
    img_rb = imopen(i7, se7);
    
    img_binary{ii} = bwareaopen(img_rb, 50); % remove particles below 50 pixels
%=========================================================================%
    
    
    tools.textbar([ii, n]);  % if more than one image, output text
end
tools.textheader();


% If a single image, cell arrays are unnecessary.
% Extract and just output images. 
if n==1
    img_binary = img_binary{1};
    img_kmeans = img_kmeans{1};
    feature_set = feature_set{1};
end

    
end

