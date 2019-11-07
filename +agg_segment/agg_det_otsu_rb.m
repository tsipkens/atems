
% AGG_DET_OTSU_RB  Performs Otsu thresholding + a rolling ball transformation.
% Authors:  Ramin Dastanpour, Steven N. Rogak, 2016-02
%           Developed at the University of British Columbia
% Modified: Timothy Sipkens
%=========================================================================%

function [img_binary] = ...
    agg_det_otsu_rb(imgs,pixsize,minparticlesize,coeffs) 

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
%=========================================================================%


%== Step 1: Apply intensity threshold (Otsu) =============================%
level = graythresh(img); % applies Otsu thresholding
bw = imbinarize(img,level);

bw = ~imclearborder(~bw); % clear aggregates on border



%== Step 2: Rolling Ball Transformation ==================================%
img_binary = agg_segment.rolling_ball(bw,pixsize,minparticlesize,coeffs);



end
