
% Investigate Morphological Opening for different parameters on set of TEM images
% Author:   Yeshun (Samuel) Ma, 2019-06-27
%=========================================================================%

close all; clear all;


%% Initialization and image acquisition
img = struct;   % Set img as a struct for cropped, footer, and other fields

[n,p] = uigetfile('*.tif');         % Obtain filename and path
img.RawImage = imread([p,n]);       % Read image from filepath

figure(1);
displayimg(img.RawImage,'Image before processing'); % Display image


%% Crop and extract image information
figure(2);
[img,pixsize] = tools.get_footer_scale(img);    % Obtain pixel size and cropped image
displayimg(img.Cropped,'Cropped Image');        % Display cropped image


%% Apply Morphological Opening on Cropped Image
% se = strel('disk',5);
upperbound = 100;
disksizes = 1:1:upperbound;

figure(3);
for ii = 1:length(disksizes)
    se = strel('disk',disksizes(ii));
    displayimg(imclose(img.Cropped,se),...
        ['Disk of Size ',num2str(disksizes(ii)),' px']);
%     displayimg(imopen(img.Cropped,se),...
%         ['Disk of Size ',num2str(disksizes(ii)),' px']);
    
    M(ii) = getframe(gcf); % record current frame
end

% img.Opened = imopen(img.Cropped,se);displayimg(img.Opened,'Morphological Opening');

figure(3); % figure to show movie of progressive opening
movie(gcf,M); % show video

%% Accessory functions ===========================================%
% Consumes an image and a title, displays a figure with this image and
% title
function displayimg(i,t)
    imagesc(i);title(t); % imagesc shows the image in a standard size 
                         % window with a colormap (specified below)
    colormap('gray');
end

