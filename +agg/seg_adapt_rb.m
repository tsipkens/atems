
% SEG_ADAPT_RB  Performs adaptive thresholding + a rolling ball transformation.
% Author: Timothy Sipkens, 2019-11-06
%=========================================================================%

function [imgs_binary] = seg_adapt_rb(imgs, ...
    sensitivity, pixsizes, minparticlesize, coeffs) 

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

n = length(imgs); % number of images to consider

if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = ones(size(img)); end
if length(pixsizes)==1; pixsizes = pixsizes .* ones(size(imgs)); end % extend if scalar

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

if ~exist('sensitivity','var'); sensitivity = []; end
if isempty(sensitivity); sensitivity = 0.52; end
%-------------------------------------------------------------------------%


% Loop over images, calling seg function below on each iteration.
imgs_binary{n} = []; % pre-allocate cell

for ii=1:n
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
%== CORE FUNCTION ========================================================%
    %== Step 1: Apply intensity threshold (Otsu) =========================%
    level = adaptthresh(img, sensitivity,...
        'ForegroundPolarity', 'dark');
            % applies adaptive thresholding
    bw = ~imbinarize(img, level);
    
    bw = imclearborder(bw); % clear aggregates on border

    %== Step 2: Rolling Ball Transformation ==============================%
    imgs_binary{ii} = agg.rolling_ball(bw, pixsize, minparticlesize, coeffs);
%=========================================================================%
    
end

end
