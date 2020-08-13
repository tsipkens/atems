
% SEG_OTSU_RB  Performs Otsu thresholding + a rolling ball transformation.
% Authors:  Ramin Dastanpour, Steven N. Rogak, 2016-02
%           Developed at the University of British Columbia
% Modified: Timothy Sipkens
%=========================================================================%

function [img_binary] = seg_otsu_rb(...
    imgs, pixsizes, minparticlesize, coeffs) 

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
    %== Step 1: Apply intensity threshold (Otsu) =========================%
    level = graythresh(img); % applies Otsu thresholding
    bw = imbinarize(img,level);

    % bw = ~imclearborder(~bw); % clear aggregates on border


    %== Step 2: Rolling Ball Transformation ==============================%
    img_binary{ii} = agg.rolling_ball(bw,pixsize,minparticlesize,coeffs);
    img_binary{ii} = ~img_binary{ii};
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
