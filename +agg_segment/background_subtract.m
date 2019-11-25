
% BACKGROUND_SUBTRACT Subtracts the background from the image.
% Author: Timothy Sipkens, 2019-11-13
%=========================================================================%

function [img,bg] = background_subtract(img)


[X,Y] = meshgrid(1:size(img,2),1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]),double(img(:)),'poly22');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(img)+t0;
t2 = t1-min(min(t1));
img = uint8(round(255.*t2./max(max(t2))));


end

