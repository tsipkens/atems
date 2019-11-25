
% AGG_DET_TEST A function for testing new aggregate segmentations.
% Author:   Timothy Sipkes, 2019-10-04
%=========================================================================%

function [img_binary] = ...
    agg_det_test(imgs,pixsize,minparticlesize,coeffs)


%== Parse inputs =========================================================%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

if ~exist('minparticlesize','var'); minparticlesize = []; end
if isempty(minparticlesize); minparticlesize = 4.9; end

if ~exist('coeffs','var'); coeffs = []; end
if isempty(coeffs)
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
        % coefficients for automatic Hough transformation
    if pixsize <= 0.181
        coeffs = coeff_matrix(1,:);
    elseif pixsize <= 0.361
        coeffs = coeff_matrix(2,:);
    else 
        coeffs = coeff_matrix(3,:);
    end
end
%-------------------------------------------------------------------------%



img = imgs{1};

[img0,bg] = agg_segment.background_subtract(img);
img1 = imbilatfilt(img0);

i1 = img1;
i1 = imgaussfilt(i1,5);

lvl = graythresh(i1);
i2b = ~im2bw(i1,lvl);
i2 = ~im2bw(i1,lvl*1.15);

se3 = strel('disk',4);
i3 = imclose(i2,se3);

i5 = zeros(size(i2));
bw1 = bwlabel(i3);
for ii=1:max(max(bw1))
    if any(i2b(bw1==ii)==1)
        i5(bw1==ii) = 1;
    end
end

img_binary = i5;

end

