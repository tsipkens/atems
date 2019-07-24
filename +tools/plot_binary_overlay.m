
% PLOT_BINARY_OVERLAY  Plot original image with binary mask overlayed
% Author:              Timothy Sipkens, 2019-07-24
%=========================================================================%

function h = plot_binary_overlay(img,img_binary)

%-{
img_edge = edge(img_binary,'sobel');
SE = strel('disk',1);
img_dilated = imdilate(img_edge,SE);
    % use dilation to strengthen the Aggsregate's outline

t0 = imimposemin(img,img_dilated);
imshow(t0);
%}

%{
SE = strel('disk',2);
img_dilated = imdilate(img_binary,SE);
img_edge = ~(img_binary-img_dilated);

t0 = img.*uint8(~img_binary);
t1 = img.*uint8(img_edge);

hl = 0.8;
imshow(hl.*t1 + (1-hl).*t0);
%}

if nargout>0; h = gca; end

end

