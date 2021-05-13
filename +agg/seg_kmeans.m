
% SEG_KMEANS  Performs k-means clustering on a modified feature set.
%  
%  This function applies a k-means segmentation approach following 
%  Sipkens and Rogak (2021) and using three feature layers: 
%  
%  FEATURE 1. a *denoised* version of the image, 
%  
%  FEATURE 2. a measure of *texture* in the image, and 
%  
%  FEATURE 3. an Otsu-like classified image, with the 
%  *threshold adjusted* upwards. 
%  
%  Compiling these different feature layers results in a three 
%  layer image (see FEATURE_SET output) that will be used for segmentation. 
%  This is roughly equivalent to segmenting colour images, if each of 
%  the layers was assigned a colour. For example, compilation of these 
%  feature layers for the sample images results in the following feature 
%  layers and compiled RGB image. More details of the method are 
%  given in the associated paper (Sipkens and Rogak, 2021). Finally,  
%  applying Matlab's `imsegkmeans(...)` function, one achieved a 
%  classified image.
%  
%  While this will likely be adequate for many users, the 
%  technique still occasionally fails, particularly if the 
%  function does not adequately remove the background. The 
%  method also has some notable limitations when images are 
%  (i) *zoomed in* on a single aggregate while (ii) also slightly 
%  overexposed. 
%  
%  The k-means method is associated with configuration files 
%  (cf., +agg/config/), which include different versions and allow 
%  for tweaking of the options associated with the method. 
%  See VERSIONS below for more information. 
%  
%  ------------------------------------------------------------------------
%  
%  VERSIONS: 
%   Previous versions, deprecated, used different feature layers and weights.
%    <strong>6+</strong>:  Three, equally-weighted feature layers as  
%         described by Sipkens and Rogak (J. Aerosol Sci., 2021). 
%    <strong>6.1</strong>: Improves the adjusted feature layer 
%         for clumpy aggregates.
%    <strong>6.2</strong>: Switches to s-curve fitting for  
%         computing the adjusted threhold layer.
%  
%  ------------------------------------------------------------------------
% 
%  IMG_BINARY = agg.seg_kmeans(IMGS) requires an IMGS data structure, with 
%  a cropped version of the images and the pixel sizes. The output is a 
%  binary mask. 
% 
%  IMG_BINARY = agg.seg_kmeans(IMGS,PIXSIZES) uses a cell array of cropped
%  images, IMGS, and an array of pixel sizes, PIXSIZES. The cell array of
%  images can be replaced by a single image. The pixel size is given in
%  nm/pixel. If not given, 1 nm/pixel is assumed, with implications for the
%  rolling ball transform. As before, the output is a binary mask. 
% 
%  IMG_BINARY = agg.seg_kmeans(IMGS,PIXSIZES,OPTS) adds a options data 
%  structure that controls the minimum size of aggregates (in pixels) 
%  allowed by the program. 
% 
%  [IMG_BINARY,IMG_KMEANS] = agg.seg_kmeans(...) adds an output for the raw
%  k-means clustered results, prior to the rolling ball transform. 
% 
%  [IMG_BINARY,IMG_KMEANS,FEATURE_SET] = agg.seg_kmeans(...) adds an 
%  additional output for false RGB images with one colour per feature layer 
%  used by the k-means clustering. 
%  
%  ------------------------------------------------------------------------
%  
%  AUTHOR: Timothy Sipkens, 2020-08-13

function [img_binary, img_kmeans, feature_set] = ...
    seg_kmeans(imgs, pixsizes, opts)


%-- Parse inputs ---------------------------------------------------------%
if ~exist('pixsizes', 'var'); pixsizes = []; end
[imgs, pixsizes, n] = agg.parse_inputs(imgs, pixsizes);
if isempty(pixsizes)
    error('PIXSIZES is a required argument unless Imgs structure is given.');
end

default_opts = '+agg/config/v6.1.json';  % default, load this config file
if ~exist('opts', 'var'); opts = []; end  % if no opts specified

% If is pre-specified structure, 
% load and partially/fully overwrite defaults.
if isstruct(opts)
    opts0 = tools.load_config(default_opts);  % load defaults
    fields = fieldnames(opts);  % field names of input
    for ii=1:length(fields)  % loop through input fields and overwrite
        opts0.(fields{ii}) = opts.(fields{ii});  % overwrite
    end
    opts = opts0;

% If string, assume load from file name.
elseif isa(opts, 'char')
    if strcmp(opts((end-3):end), 'json')  % expects JSON file path
        opts = tools.load_config(opts);
    else  % otherwise, input is expected to be version number (e.g., 'v6.1')
        opts = tools.load_config(['+agg/config/', opts, '.json']);
    end

% Otherwise, load default properties. 
else
    opts = tools.load_config(default_opts);
end
%-------------------------------------------------------------------------%


tools.textheader('k-means');

% Loop over images, calling seg function below on each iteration.
img_binary{n} = []; % pre-allocate cells
img_kmeans{n} = [];
feature_set{n} = [];

disp(' Segmenting images:'); tools.textbar([0, n]);
for ii=1:n
    
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
    
%== CORE FUNCTION ========================================================%
    morph_param = 0.8 / pixsize; % parameter used to adjust morphological operations
    
    
    %== STEP 1: Attempt to the remove background gradient ================%
    img = agg.bg_subtract(img); % background subtraction
    tools.textbar([(ii-1)+0.45, n]);
    
    
    
    %== STEP 2: Pre-process image ========================================%
    %-- A: Perform denoising ---------------------------------------------%
    img_denoise = imbilatfilt(img);
    % img_denoise = tools.imtotvar_sb_atv(img,15); % alternate total variation denoise
    tools.textbar([(ii-1)+0.49, n]); % partial textbar update
    
    
    
    %-- B: Use texture in bottom hat images ------------------------------%
    se = strel('disk', 20);
    i10 = imbothat(img_denoise, se);

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
    % NOTE: For original v6, lvl3 went up to 1.25, which, while faster, 
    %  caused problems for particularily clumpy aggregates. 
    %  Subsequent updates may cause some minor differences
    %  relative to Sipkens and Rogak (2021).
    lvl3 = opts.lvl3;
    n_in = ones(size(lvl3));
    for ll=1:length(lvl3) % loop, increasing the threshold level
        n_in(ll) = sum(sum(~im2bw(i1, min(lvl2 * lvl3(ll), 1))));
            % min(*, 1) prevents loop from going above max. brightness
    end
    n_in = movmean(n_in, 10); % apply moving average to smooth out curve, remove kinks
    
    %-- Fit a curve --%
    % OPTION 1: Fit a linear trend to the first ten points.
    % Then look for deviationf rom trend.
    if strcmp(opts.lvlfun, 'lin')
        p = polyfit(lvl3(1:10), n_in(1:10), 1); % fit linear curve to inital points
        n_in_pred = p(1).*lvl3 + p(2); % predicted values of number of pixels in aggregates
        lvlfun = (n_in - n_in_pred) ./ (n_in_pred + eps);
    
    % OPTION 2: Fit an s-curve to a larger range.
    % Look for lvl5 from bottom of s-curve.
    else
        fun = @(x) max(n_in) ./ (1 + exp(-x(1) .* (lvl3 - x(2))));
        x1 = lsqnonlin(@(x) n_in - fun(x), [60, 1.2], ...
            [], [], struct('Display', 'off'));
        lvlfun = fun(x1) ./ max(n_in);
    end
    lvl4 = find(lvlfun > opts.lvl5);  % cases that devaite lvl5% from initial trend
    
    % If nothing found, revert to Otsu.
    % To debug, one can plot the Otsu result using: 
    %  tools.imshow_binary(imgs{ii}, i2a);
    % or 
    %  plot(lvl3, n_in);
    % Results more often for dense aggregates.
    if isempty(lvl4)
        lvl4 = 1;
        warning(['Adjusted threshold failed on image no. ', ...
            num2str(ii), '. Using Otsu.']);
        disp(' ');
        tools.textbar([0, n]); tools.textbar([(ii-1)+0.7, n]);
    end
    
    lvl4 = lvl3(lvl4(1)); % use the first case found in preceding line
    i2b = ~im2bw(i1, lvl2 * lvl4); % binary at a fraction above Otsu threshold
    
    % Close the higher threshold image 
    % to remove noisy points now included in binary.
    se3 = strel('disk', max(round(5*morph_param), 1));
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
    feature_set{ii} = single(cat(3, ...
        i12, i5, img_denoise));
    
    
    
    
    %== STEP 3: Perform kmeans segmentation ==============================%
    bw = imsegkmeans(feature_set{ii}, 2);
    bw = bw==1;

    [~,ind_max] = max([mean(img_denoise(bw)),mean(img_denoise(~bw))]);
    img_kmeans{ii} = bw==(ind_max-1);
    
    tools.textbar([(ii-1)+0.99, n]); % partial textbar update
    
    
    
    %== STEP 4: Rolling Ball Transformation ==============================%
    % Disk size limited by size of holes in particle.
    ds = round(opts.morphsc * morph_param);
    se6 = strel('disk', max(ds, 1));
    i7 = imclose(img_kmeans{ii}, se6);
    
    % Disk size must be less than se6 to 
    % maintain connectivity. 
    se7 = strel('disk', max(ds-1, 0));
    img_rb = imopen(i7, se7);
    
    % Remove particles below opts.minsize pixels.
    % By default, removes aggregates smaller than 50 pixels.
    img_binary{ii} = bwareaopen(img_rb, opts.minsize);
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

