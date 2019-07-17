
% PREPROCESS    Perform preprocessing of image.
% Author:       Timothy Sipkens, 2019-06-24; Yiling Kang, 2018
% Originally:   Ben Gigone and Emre Karatas, PhD
% ciations:     Kook et al. 2016, SAE
%=========================================================================%

function [img_analyze,img_Canny,img_binary] = ...
    preprocess(img,imgFoldName,aggNum,bool_plot)

%== Preprocessing ========================================================%
%-- Converts cropped image to a binary image (using thresholding UI) -----%
[img_binary] = thresholding_ui.Agg_det_Slider(img.Cropped_agg,0);
img_binary = ~img_binary;


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

%-- Erasing background by multiplying binary image with grayscale image --%
img_analyze = double(img_binary) .* double(II1_mf);
if bool_plot % FIGURE 4
    figure();
    imshow(img_analyze, []);
    title('Step 4: Background Erasing')
end


%-- Canny Edge Detection -------------------------------------------------%
img_Canny0 = edge(img_analyze,'Canny'); % MATLAB Canny edge detection 
if bool_plot % FIGURE 5
    figure(); % plot Canny edges
    imshow(img_Canny0);
    title('Step 5: Canny Edge Detection');
    saveas(gcf, [imgFoldName,'\edge_',int2str(aggNum)], 'tif')
end


%-- Imposing white background onto image ---------------------------------%
%   This precent the program from detecting any background particles
img_Canny = double(~img_binary) + double(img_Canny0);
if bool_plot % FIGURE 6
    figure();
    imshow(img_Canny);
    title('Step 6: Binary Image Overlap')
end

end

