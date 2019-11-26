
% SEG_ADAPT_RB  Performs adaptive thresholding + a rolling ball transformation.
% Author: Timothy Sipkens, 2019-11-06
%=========================================================================%

function [img_binary] = ...
    seg_adapt_rb(imgs,sensitivity,pixsize,minparticlesize,coeffs) 

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
if isempty(pixsize); pixsize = ones(size(img)); end

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

if ~exist('sensitivity','var'); sensitivity = []; end
if isempty(sensitivity); sensitivity = 0.6; end
%=========================================================================%



%== Step 1: Apply intensity threshold (Otsu) =============================%
level = adaptthresh(img,sensitivity,...
    'ForegroundPolarity','dark');
        % applies adaptive thresholding
bw = imbinarize(img,level);

% bw = ~imclearborder(~bw); % clear aggregates on border



%== Step 2: Rolling Ball Transformation ==================================%
img_binary = agg.rolling_ball(bw,pixsize,minparticlesize,coeffs);
img_binary = ~img_binary;


end
