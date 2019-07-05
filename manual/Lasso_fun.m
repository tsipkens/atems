%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

%% This function allows user to draw an approximate boundary around the aggregate
function [binaryImage,xy_lasso,x_lasso,y_lasso,burnedImage,maskedImage] = Lasso_fun(Cropped_im)

font_size = 10;
%% Displaying cropped image
figure; imshow(Cropped_im);
title('Original CROPPED Sample Image', 'FontSize', font_size);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

%% Freehand drawing
message = sprintf('Please draw an approximate boundary around the aggregate.\nLeft click and hold to begin drawing.\nLift mouse button to finish');
uiwait(msgbox(message));
hFH = imfreehand();

%% Create a binary image ("mask") from the ROI object.
binaryImage = hFH.createMask();

%% Get coordinates of the boundary of the freehand drawn region.
structBoundaries = bwboundaries(binaryImage);
xy_lasso=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
x_lasso = xy_lasso(:, 2);	% Columns.
y_lasso = xy_lasso(:, 1);	% Rows.

%% Burn line into image by setting it to 255 wherever the mask is true.
burnedImage = Cropped_im;
burnedImage(binaryImage) = 255;

%% Mask the image and display it.
% Will keep only the part of the image that's inside the mask, zero outside mask.
maskedImage = Cropped_im;
maskedImage(~binaryImage) = 1;
close all