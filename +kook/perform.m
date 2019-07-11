
% PERFORM   Original Kook function, modified only to be incorporated into a function.
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
% 1. TEMscale -> pixsize.
% 2. Included references to img.
% 3. Updates to commenting.
%=========================================================================%

function [dpdist] = perform(img)
%-------------------------------------------------------------------------%
% Inputs:
%   img     Image struct to be analyzed
%   dpdist  Primary particle size disitrbution of aggregate
%-------------------------------------------------------------------------%


%-- Parse inputs ---------------------------------------------------------%
if img.num == 1
    FileName = char(img.files); 
else
    FileName = char(img.files(img_counter,1));
end
img.RawImage = imread([img.dir,FileName]); % read in image
[img,pixsize] = tools.get_footer_scale(img);

maxImgCount = 255; % Maximum image count for 8-bit image
SelfSubt = 0.8; % Self-subtraction level
mf = 1; % Median filter [x x] if needed
alpha = 0.1; % Shape of the negative Laplacian “unsharp” filter 0?1
rmax = 30; % Maximum radius in pixel
rmin = 4; % Minimun radius in pixel
sens_val = 0.75; % the sensitivity (0->1) for the circular Hough transform

II1 = img.Cropped;
OriginalImg = II1;



%== Pre-processing =======================================================% 
%-- Step 1: Invert image greyscale ---------------------------------------%
if size(OriginalImg,1) > 900
	II1(950:size(II1,1), 1:250) = 0;% ignore scale bar in the TEM image x 1-250 pixel and y 950-max pixel
end

II1_bg=SelfSubt*II1; % Self-subtration from the original image
II1=maxImgCount-II1;
II1=II1-II1_bg;
II1(II1<0)=0;
figure();imshow(II1, []);title('Step 1: Inversion and self-subtraction');
% - step 2: median filter to remove noise
II1_mf=medfilt2(II1, [mf mf]);
figure();imshow(II1_mf, []);title('Step 2: Median filter');
% - step 3: Unsharp filter
f = fspecial('unsharp', alpha);
II1_lt = imfilter(II1_mf, f);
figure();imshow(II1_lt, []);title('Step 3: Unsharp filter');


%-- Canny edge detection -------------------------------------------------%
BWCED = edge(II1_lt,'canny'); % perfrom Canny edge detection
figure();imshow(BWCED);title('Step 4: Canny edge detection');



%== Main processing steps ================================================%
%-- Find circles within soot aggregates ----------------------------------%
[centersCED, radiiCED, metricCED] = imfindcircles(BWCED,[rmin rmax],...
    'objectpolarity', 'bright', 'sensitivity', sens_val, 'method', 'TwoStage');
% - draw circles
figure();imshow(OriginalImg,[]);hold;
h = viscircles(centersCED, radiiCED, 'EdgeColor','r');
title('Step 5: Parimary particles overlaid on the original TEM image');


%-- Check the circle finder ----------------------------------------------%
%-- Overlaying the CHT boundaries on the original image. 
R = imfuse(BWCED, OriginalImg,'blend');
figure();imshow(R,[],'InitialMagnification',500);hold;h = viscircles(centersCED, radiiCED, 'EdgeColor','r');
title('Step 6: Primary particles overlaid on the Canny edges and the original TEM image');
dpdist = radiiCED*pixsize*2;


end
