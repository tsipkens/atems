
% SEG_OTSU  Performs Otsu thresholding + a rolling ball transformation.
%  
%  [IMG_BINARY] = agg.seg_otsu(IMGS) requires an IMGS data structure, with 
%  a cropped version of the images and the pixel sizes. The output is a 
%  binary mask. 
%  
%  [IMG_BINARY] = agg.seg_otsu(IMGS,PIXSIZES) uses a cell array of cropped
%  images, IMGS, and an array of pixel sizes, PIXSIZES. The cell array of
%  images can be replaced by a single image. The pixel size is given in
%  nm/pixel. If not given, 1 nm/pixel is assumed, with implications for the
%  rolling ball transform. As before, the output is a binary mask. 
%  
%  [IMG_BINARY] = agg.seg_otsu(IMGS,PIXSIZES,MINPARTICLESIZE,COEFFS) 
%  adds inputs to control the agg.rolling_ball(...) call. See that function 
%  for more information on these inputs.
% 
%  AUTHORS: Timothy Sipkens (2020), Ramin Dastanpour (Original, 2016), Steven N. Rogak

function [img_binary] = seg_otsu(...
    imgs, pixsizes, minparticlesize, coeffs) 

%-- Parse inputs ---------------------------------------------------------%
[imgs, pixsizes, n] = agg.parse_inputs(imgs, pixsizes);

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end
%-------------------------------------------------------------------------%


tools.textheader('Otsu thresholding');

% Loop over images, calling seg function below on each iteration.
img_binary{n} = []; % pre-allocate cells
img_kmeans{n} = [];
feature_set{n} = [];

disp('Segmenting images:'); tools.textbar([0, n]);
for ii=1:n
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
%== CORE FUNCTION ========================================================%
    %== Step 0a: Remove the background. ==================================%
    %   New to this implementation.
    img = agg.bg_subtract(img);
    
    
    %== Step 0b: Perform denoising of the image ==========================%
    %   New to this implementation.
    img = imbilatfilt(img);
    
    
    %== Step 1: Apply intensity threshold (Otsu) =========================%
    level = graythresh(img); % applies Otsu thresholding
    bw = imbinarize(img, level);
    
    
    %== Step 2: Rolling Ball Transformation ==============================%
    img_binary{ii} = agg.rolling_ball(bw,pixsize,minparticlesize,coeffs);
    img_binary{ii} = ~img_binary{ii};
%=========================================================================%
    
    tools.textbar([ii, n]);
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
