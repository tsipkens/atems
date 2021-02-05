
% BG_SUBTRACT Subtracts the background from the image.
%  Employs a morphological closing, followed by fitting a surface through
%  the result. 
%  
%  [IMG_OUT] = agg.bg_subtract(IMG) subtracts the background from a 2D
%  matrix, IMG, representing the image. 
%  
%  [IMG_OUT,BG] = agg.bg_subtract(IMG) also outputs a representation of the
%  background (the fit surface).
%  
%  AUTHOR: Timothy Sipkens, 2019-11-13

function [img_out, bg] = bg_subtract(img)

%-- Rolling ball transformation to determine the background --------------%
se_bg = strel('disk', 80);
pre_bg = imclose(img, se_bg);


%-- Fit surface ----------------------------------------------------------%
%   Performs the role of removing foreground particles remaining in
%   background correction above.
[X,Y] = meshgrid(1:size(img,2), 1:size(img,1));
bg_fit = fit(double([X(:), Y(:)]), double(pre_bg(:)), 'poly22');
bg = uint8(round(bg_fit(X, Y)));

t0 = double(max(max(bg)) - bg); % inverted background
t1 = double(img) + t0;
t2 = t1 - min(min(t1));
img_out = uint8(round(255 .* t2 ./ max(max(t2))));
    % to accommodate uint8, background subtract on reversed image


end

