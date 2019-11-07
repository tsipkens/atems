
% AUTOCROP Automatically crops an image based on binary information
% Author:  Yeshun (Samuel) Ma, Timothy Sipkens, 2019-07-23
%=========================================================================%

function [img_cropped,img_binary,rect] = autocrop(img_orig,img_binary)

[x,y] = find(img_binary);

space = 25;
size_img = size(img_orig);

% Find coordinates of top and bottom of aggregate
x_top = min(max(x)+space,size_img(1)); 
x_bottom = max(min(x)-space,1);
y_top = min(max(y)+space,size_img(2)); 
y_bottom = max(min(y)-space,1);


img_binary = img_binary(x_bottom:x_top,y_bottom:y_top);
img_cropped = img_orig(x_bottom:x_top,y_bottom:y_top);
rect = [y_bottom,x_bottom,(y_top-y_bottom),(x_top-x_bottom)];

end