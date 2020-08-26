
% KOOK  Original Kook function, modified only to be incorporated as a function.
%
% Automatic primary particle finder v1.2 (works on Matlab 2012a or higher + 
% Image Processing Toolbox)
% The code implements pre-processing (Median Filter and unsharp masking), 
% Canny edge detection, and  Circular Hough Transform.
%
% Original code written by Qing Nian Chan on 18 Sep 2014
% Modified by Sanghoon Kook for diesel soot applications on 27 Sep 2014
% Last update by original authors on 19 Dec 2014 by Sanghoon Kook
% 
% Modifications by UBC: 
% 1. TEMscale -> pixsize (using tools.getfooterscale)
% 2. Included references to img
% 3. Updates to commenting
% 4. Update to output (dpdist is original output)
% 5. Added option as to whether of not to generate plots
%
%-------------------------------------------------------------------------%
%
% Inputs:
%   img        A single image to be analyzed
%   pixsize    Size of the pixels
%   f_plot     A boolean determining whether or not to generate plots
% 
%=========================================================================%

function [Pp, dp] = kook(img, pixsize, f_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('f_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end
%-------------------------------------------------------------------------%


disp('Performing original Kook analysis...');

Pp = struct; % initialize aggregate data structure


%-- Set relevant parameter values ----------------------------------------%
max_img_count = 255; % maximum image count for 8-bit image
self_subt = 0.8; % self-subtraction level
mf = 1; % median filter [x x] if needed
alpha = 0.1; % shape of the negative Laplacian “unsharp” filter 0?1
rmax = 30; % maximum radius in pixel
rmin = 6; % minimum radius in pixel
sens_val = 0.75; % the sensitivity (0->1) for the circular Hough transform
%-------------------------------------------------------------------------%


%== Pre-processing =======================================================% 
%-- STEP 1: Invert image greyscale ---------------------------------------%
i1_bg = self_subt .* img; % self-subtration from the original image
img = max_img_count - img;
img = img - i1_bg; % subtract background
img(img<0) = 0;

%-- STEP 2: median filter to remove noise --------------------------------%
i1_mf = medfilt2(img, [mf mf]);

%-- STEP 3: Unsharp filter------------------------------------------------%
f = fspecial('unsharp', alpha);
i1_lt = imfilter(i1_mf, f);

%-- STEP 4: Canny edge detection -----------------------------------------%
bw_canny = edge(i1_lt,'canny'); % perfrom Canny edge detection



%== Main processing steps ================================================%
%-- Find circles within soot aggregates ----------------------------------%
[centers, radii] = imfindcircles(bw_canny, [rmin rmax],...
    'objectpolarity', 'bright', 'sensitivity', sens_val, ...
    'method', 'TwoStage');

%-- Check the circle finder ----------------------------------------------%
%-- Overlaying the CHT boundaries on the original image. 
if f_plot==1
    figure;
    imshow(img);
    hold on;
    viscircles(centers, radii, 'EdgeColor','r');
    hold off;
end


%== Generate outputs =====================================================%
Pp.centers = centers; % output in px
Pp.radii = radii; % output in px
Pp.dp = radii * pixsize * 2; % output in nm

dp = mean(Pp.dp);

disp('Complete.');
disp(' ');

end
