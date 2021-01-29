
% SEG_OTSU_ORIG  Performs Otsu thresholding + a rolling ball transformation (as per Dastanpur et al.).
% Authors:  Ramin Dastanpour, Steven N. Rogak, 2016-02
%           Developed at the University of British Columbia
% Modified: Timothy Sipkens
% 
% Note: The method remains true to the original code by Dastanpour et al., 
%       and differs from the other implementation included with this code
%       which does not immediately remove boundary aggregates, adds
%       background subtraction, and adds a denoising step. 
%=========================================================================%

function [img_binary] = seg_otsu_orig(...
    imgs, pixsizes, minparticlesize, coeffs) 

%-- Parse inputs ---------------------------------------------------------%
[imgs, pixsizes, n] = agg.parse_inputs(imgs, pixsizes);

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end
%-------------------------------------------------------------------------%

% Loop over images, calling seg function below on each iteration.
img_binary{n} = []; % pre-allocate cell

disp('Performing Otsu thresholding (as per Dastanpour):');
if n>1; tools.textbar(0); end
for ii=1:n
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
%== CORE FUNCTION ========================================================%
    %== Step 1: Apply intensity threshold (Otsu) =========================%
    level = graythresh(img); % applies Otsu thresholding
    bw = imbinarize(img, level);
    
    bw = ~imclearborder(~bw); % clear aggregates on border
        % required due to occasional background gradients included in results
    
    
    %== Step 2: Rolling Ball Transformation ==============================%
    img_binary{ii} = agg.rolling_ball(bw,pixsize,minparticlesize,coeffs);
    img_binary{ii} = ~img_binary{ii};
%=========================================================================%
    
    if n>1; tools.textbar(ii / n); end
end
disp('Complete.');
disp(' ');

% If a single image, cell arrays are unnecessary.
% Extract and just output images. 
if n==1
    img_binary = img_binary{1};
end


end
