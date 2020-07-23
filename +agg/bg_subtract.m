
% BG_SUBTRACT Subtracts the background from the image using a rolling ball operation.
% Author: Timothy Sipkens, 2019-11-13
%=========================================================================%

function [img_out,bg] = bg_subtract(img)

%-- Rolling ball transformation to determine the background --------------%
disp('Performing background subtraction...');
se = strel('square',250); % a square is used to avoid artifacts in the corners
pre_bg = imopen(imclose(img,se),se); % rolling rectangle transformation


%-- Fit linear surface ---------------------------------------------------%
%   Performs the role of removing foreground particles remaining in
%   background correction above.
[X,Y] = meshgrid(1:size(img,2), 1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]), double(pre_bg(:)), 'poly11');
pre_bg_fit = uint8(round(bg_fit(X,Y)));


bg = imgaussfilt(min(pre_bg,pre_bg_fit),20);
    % blurr together resultant background
    
img_out = 255-((255-img)-(255-bg));
    % to accommodate uint8, background subtract on reversed image

disp('Complete.');
disp(' ');


end

