
% BACKGROUND_FNC    Smooths out background using curve fitting
% Originally by:    Ramin Dastanpour, Steven N. Rogak, Last updated in Feb. 2016
% Modified by:      Timothy Sipkens, 2019-07-16
%
% Notes:
%   This function smoothens background brightness, specially on the edges of
%   the image where intensity (brightness) has a curved planar distribution.
%   This improves thresholding in the following steps of image processing
%=========================================================================%

function img_refined = background_fnc(img_binary,img_cropped)

nagg = nnz(img_binary); % pixels within the aggregate
ntot = numel(img_cropped); % pixels within the whole cropped image 
nbg = ntot-nagg; % pixels in the backgound of the aggregate


%-- Computing average background intensity -------------------------------%
burned_img = img_cropped;
burned_img(img_binary) = 0;
mean_bg =  mean(mean(burned_img))*ntot/nbg;


%-- Replace aggregate pixels' with intensity from the background ---------%
img_bg = img_cropped;
img_bg(img_binary) = mean_bg;


%-- Fit a curved surface into Filled_img data ----------------------------%
[x_d,y_d] = meshgrid(1:size(img_bg,2),1:size(img_bg,1));
xdata = {x_d,y_d};
fun = @(c,xdata) c(1).*xdata{1}.^2+c(2).*xdata{2}.^2+c(3).*xdata{1}.*xdata{2}+...
    c(4).*xdata{1}+c(5).*xdata{2}+c(6);

c_start = [0 0 0 0 0 mean_bg];
options = optimset('MaxFunEvals',1000);
options = optimset(options,'MaxIter',1000); 
[c] = lsqcurvefit(fun,c_start,xdata,double(img_bg),[],[],options);


%-- Build the fitted surface ---------------------------------------------%
img_bg_fit = zeros(size(img_bg));
for ii = 1:size(img_bg,1)
    for jj = 1:size(img_bg,2)
        img_bg_fit(ii,jj) = ...
            c(1)*ii^2+c(2)*jj^2+c(3)*ii*jj+c(4)*ii+c(5)*jj+c(6);
    end
end


%-- Refine Cropped_img, using fitted surface -----------------------------%
img_refined = mean_bg+double(img_cropped)-img_bg_fit;
img_refined = uint8(img_refined);

end