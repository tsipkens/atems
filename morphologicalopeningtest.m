% Investigate Morphological Opening for different parameters on set of TEM
% Images

close all; clear all;

%% Initialization and image acquisition
img = struct;   % Set img as a struct for cropped, footer, and other fields

[n,p] = uigetfile('*.tif');         % Obtain filename and path
img.RawImage = imread([p,n]);       % Read image from filepath

displayimg(img.RawImage,'Image before processing'); % Display image

%% Crop and extract image information
[img,pixsize] = tools.get_footer_scale(img);    % Obtain pixel size and cropped image
displayimg(img.Cropped,'Cropped Image');        % Display cropped image

%% Apply Morphological Opening on Cropped Image
% se = strel('disk',5);
upperbound = 10;
disksizes = 1:1:upperbound;

for i = disksizes
    se = strel('disk',i);
    displayimg(imopen(img.Cropped,se),['Disk of Size',num2str(i)]);
end

% img.Opened = imopen(img.Cropped,se);displayimg(img.Opened,'Morphological Opening');


%% Accessory functions
% Consumes an image and a title, displays a figure with this image and
% title
function displayimg(i,t)
    figure();imshow(i);title(t);
end

