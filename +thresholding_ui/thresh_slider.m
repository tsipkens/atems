
% Thresholding the image as a part of semi-automatic particle detection
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% Slider method
%=========================================================================%

function thresh_slider(hObj,event,hax,thresh_slider_in,binaryImage) %#ok<INUSL>

global Binary_Image_4

%-- Average filter -------------------------------------------------------%
hav = fspecial('average');
img_filtered = imfilter(thresh_slider_in, hav);


%-- Median ---------------------------------------------------------------%
% Examines a neighborhood of WxW matrix, takes and makes the centre of that
% matrix the median of the original neighborhood
W = 5;
thresh_slider_in = medfilt2(img_filtered,[W W]);


%-- Binary image via threshold value -------------------------------------%
adj = get(hObj,'Value');
level = graythresh(thresh_slider_in);
level = level+adj;
img_binary1 = imbinarize(thresh_slider_in,level);


%-- Binary image via dilation --------------------------------------------%
%   Reduces initial noise and fill initial gaps
SE1 = strel('square',1);
img_binary2 = imdilate(~img_binary1,SE1);


%-- Refining binary image. Before refinig, thresholding causes some ------%
%   Errors, initiating from edges, grows towards the aggregate. In
%   this section, external boundary, or background region, is utilized to
%   eliminate detection errors in the background region.
img_binary3 = 0.*img_binary2;
img_binary3(binaryImage) = img_binary2(binaryImage);
Binary_Image_4 = logical(img_binary3);

img_temp2 = imimposemin(thresh_slider_in,Binary_Image_4);

axes(hax);
% cla;
imshow(img_temp2);

end