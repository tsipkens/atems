
% PREPROCESS    Perform preprocessing of image.
% Author:       Timothy Sipkens, 2019-06-24; Yiling Kang, 2018
% Originally:   Ben Gigone and Emre Karatas, PhD
% ciations:     Kook et al. 2016, SAE
%=========================================================================%

function [img,BWCED2,binary_cropped] = preprocess(img,imgFoldName,aggNum)

%== Preprocessing ========================================================%
%-- Converts cropped image to a binary image (using thresholdin UI) ------%
[binary_cropped] = thresholding_ui.Agg_det_Slider(img.Cropped_agg,0);
binary_cropped = ~binary_cropped;


%-- Fix background illumination ------------------------------------------%
se = strel('disk',85);
II1 = imbothat(img.Cropped_agg,se);
figure
imshow(II1,[])
title('Step 1: Black Top Hat Filter'); % FIGURE 1


%-- Enhance Contrast -----------------------------------------------------%
II1 = imadjust(II1);
figure()
imshow(II1, [])
title('Step 2: Contrast Enhanced');   %FIGURE 2


%-- Median Filtering -----------------------------------------------------%
%   Step 3: median filter to remove noise 
II1_mf = medfilt2(II1); %, [mf mf]); 

imshow(II1_mf, []); % show pro-processed image
title('Step 3: Median filter'); % FIGURE 3 

saveas(gcf, [imgFoldName,'\prep_',int2str(aggNum)], 'tif');
    % save the results of pre-processing

    
%== RawImage processing ==================================================%
%   Background erasing, Canny edge detection, background inversion, 
%   Circular Hough Transform

%-- Erasing background by multiplying binary image with grayscale image---%
img.Analyze = double(binary_cropped) .* double(II1_mf);
figure();
imshow(img.Analyze, []);
title('Step 4: Background Erasing') % FIGURE 4


%-- Canny Edge Detection -------------------------------------------------%
BWCED = edge(img.Analyze,'Canny'); % MATLAB Canny edge detection 

figure(); % plot Canny edges
imshow(BWCED);
title('Step 5: Canny Edge Detection'); % FIGURE 5

saveas(gcf, [imgFoldName,'\edge_',int2str(aggNum)], 'tif')


%-- Imposing white background onto image ---------------------------------%
%   This precent the program from detecting any background particles
BWCED2 = double(~binary_cropped) + double(BWCED);
figure();
imshow(BWCED2);
title('Step 6: Binary Image Overlap') % FIGURE 6


end

