
% ROLLING_BALL Perform a rolling ball transformation.
% Author: Ramin Dastanpour
% Modified: Ramin DastanpourTimothy Sipkens, 2019-11-06
%=========================================================================%

function [img_binary] = ...
    rolling_ball(img_binary,pixsize,minparticlesize,coeffs)


%== Parse inputs =========================================================%
if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = 0.1; end

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
%=========================================================================%



%== Rolling Ball Transformation ==========================================%
%   imclose opens white areas
%   imopen opens black areas
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);

se = strel('disk',round(a*minparticlesize/pixsize));
img_bewBW = imclose(img_binary,se);

se = strel('disk',round(b*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW,se);

se = strel('disk',round(c*minparticlesize/pixsize));
img_bewBW = imclose(img_bewBW,se);

se = strel('disk',round(d*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW,se);



%== Delete blobs under a threshold area size =============================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
if nparts>50 % if a lot of particles, remove more particles
    mod = 10;
    disp(['Found too many particles, removing particles below: ',...
        num2str(e*mod),' nm.']);
else
    mod = 1;
end
    
for kk = 1:nparts
    area = length(CC.PixelIdxList{1,kk})*pixsize^2;
    
    if area <= (mod*e*minparticlesize/pixsize)^2
        img_bewBW(CC.PixelIdxList{1,kk}) = 1;
    end
end


img_binary = img_bewBW;


end

