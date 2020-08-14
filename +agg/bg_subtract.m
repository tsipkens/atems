
% BG_SUBTRACT Subtracts the background from the image using a rolling ball operation.
% Author: Timothy Sipkens, 2019-11-13
%=========================================================================%

function [img_out, bg] = bg_subtract(img)

%-- Rolling ball transformation to determine the background --------------%
se_bg = strel('disk',80);
pre_bg = imclose(img,se_bg);


%-- Fit linear surface ---------------------------------------------------%
%   Performs the role of removing foreground particles remaining in
%   background correction above.
[X,Y] = meshgrid(1:size(img,2), 1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]), double(pre_bg(:)), 'poly22');
pre_bg_fit = uint8(round(bg_fit(X,Y)));

bg = pre_bg_fit;
% bg = imgaussfilt(min(pre_bg, pre_bg_fit), 20);
    % blurr together resultant background
    
t0 = double(max(max(bg)) - bg); % inverted background
t1 = double(img) + t0;
t2 = t1 - min(min(t1));
img_out = uint8(round(255.*t2./max(max(t2))));
    % to accommodate uint8, background subtract on reversed image


end

