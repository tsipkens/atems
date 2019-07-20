% AUTOMATIC/SEMI-AUTOMATIC AGGREGATE DETECTION
% Parameters:
%   - img:  img struct containing fname, rawimage, cropped image, footer,
%           ocr, and pixel size
% Return Types:
%	- binary:	binary image from running threshold slider
%	- dilated:	dilated image from running imdilate on Sobel edge detection
%	- imposed:	imposed image of cropped and dilated edge

function [binary,dilated,imposed] = detectAggregate(img)

% Initialize Parameters
pixsize = img.pixsize;
minparticlesize = 4.9; % to filter out noises
% Coefficient for automatic Hough transformation
coeff_matrix    = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
    0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
moreaggs    = 0;


% Build the image processing coefficients for the image based on its
% magnification
if pixsize <= 0.181
    coeffs = coeff_matrix(1,:);
elseif pixsize <= 0.361
    coeffs = coeff_matrix(2,:);
else 
    coeffs = coeff_matrix(3,:);
end

% Run slider to obtain binary image
binary = thresholding_ui.Agg_detection(img,pixsize, ...
    moreaggs,minparticlesize,coeffs);
    
img.Edge   		= edge(binary,'sobel'); % Sobel edge detection
SE              = strel('disk',1);
dilated         = imdilate(img.Edge,SE); % morphological dilation
    
clear img.Edge SE2

% Obtain imposed image
imposed = imimposemin(img.Cropped, dilated);

end