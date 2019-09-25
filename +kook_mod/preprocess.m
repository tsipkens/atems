
% PREPROCESS    Perform preprocessing of image.
% Author:       Timothy Sipkens, 2019-06-24; Yiling Kang, 2018
% Originally:   Ben Gigone and Emre Karatas, PhD
% ciations:     Kook et al. 2016, SAE
%
% Preprocesses the cropped aggregate using background subtraction and
% various techniques.  Works on one aggregate.
%
% Parameters:   agg_cropped - cropped image of aggregate
%               agg_binary - cropped binary image of aggregate
%=========================================================================%

function [img_Canny,Data] = ...
    preprocess(img_cropped,img_binary)


%-- Fix background illumination ------------------------------------------%
se = strel('disk',85);
Data.img_bothat = imbothat(img_cropped,se);


%-- Enhance Contrast -----------------------------------------------------%
Data.img_contrast = imadjust(Data.img_bothat);


%-- Median Filtering -----------------------------------------------------%
%   Step 3: median filter to remove noise 
Data.img_medfilter = medfilt2(Data.img_contrast); %, [mf mf]); 

    
%== RawImage processing ==================================================%
%   Background erasing, Canny edge detection, background inversion, 
%   Circular Hough Transform

%-- Erasing background by multiplying binary image with grayscale image --%
Data.img_analyze = uint8(img_binary).*Data.img_medfilter ;


%-- Canny Edge Detection -------------------------------------------------%
img_Canny0 = edge(Data.img_analyze,'Canny'); % MATLAB Canny edge detection


%-- Imposing white background onto image ---------------------------------%
%   This prevents the program from detecting any background particles
img_Canny = double(~img_binary) + double(img_Canny0);
Data.img_Canny = img_Canny;

end

