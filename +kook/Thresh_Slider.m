function Thresh_Slider(hObj,event,ax) %#ok<INUSL>
% Thresholding the image as a part of smi-automatic particle detection
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% Slider method

global Thresh_slider_in binaryImage Binary_Image_4

%% Average filter
hav = fspecial('average');
Filtered_Image_1 = imfilter(Thresh_slider_in, hav);
clear hav

%% Median filter
% Examines a neighborhood of WxW matrix, takes and makes the centre of that
% matrix the median of the original neighborhood
W = 5;
Thresh_slider_in = medfilt2(Filtered_Image_1 , [W W]);

%% Binary image via threshold value
adj = get(hObj,'Value');
level = graythresh(Thresh_slider_in);
level = level+adj; 
Binary_Image_1 = im2bw(Thresh_slider_in,level);

%% Binary image via Dilation  
% to reduce initial noise and fill initial gaps
SE1 = strel('square',1);
Binary_Image_2 = imdilate(~Binary_Image_1,SE1);

%% Refining binary image. Before refinig, thresholding causes some
% errors, initiating from edges, grows towards the aggregate. In
% this section, external boundary, or background region, is utilized to
% eliminate detection errors in the background region.
Binary_Image_3=0.*Binary_Image_2;
Binary_Image_3(binaryImage)=Binary_Image_2(binaryImage);
Binary_Image_4=logical(Binary_Image_3);

%%
temp_image2=imimposemin(Thresh_slider_in,Binary_Image_4);
imshow(temp_image2);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
