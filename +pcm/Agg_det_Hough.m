
% AGG_DET_HOUGH  Hough Transformation and Rolling Ball Transformation
% Automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
%=========================================================================%

function [img_binary,moreaggs,choice] = ...
    Agg_det_Hough(img_cropped,npix,moreaggs,minparticlesize,coeffs) 


%== Step 1: Apply intensity threshold ====================================%
level = graythresh(img_cropped);
BW = imbinarize(img_cropped,level);
figure;
hold on;
subplot(3,3,1);imshow(img_cropped)
subplot(3,3,2); imshow(BW)
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);


%== Step 2: Remove aggregates touching the edge of the image =============%
BWedge = BW;
BWedge(2:size(BW,1)-1,2:size(BW,2)-1) = 1;
[x,y] = find(BWedge == 0);
p = length(x);
q = 1;
while q<=p
    if x(q)+1 <= size(BW,1)
        if BW(x(q)+1,y(q)) == 0
            p = p+1;
            x(p) = x(q)+1;
            y(p) = y(q);
            BW(x(q)+1,y(q)) = 1;
        end
    end
    if x(q)-1 >= 1 
        if BW(x(q)-1,y(q)) == 0
            p = p+1;
            x(p) = x(q)-1;
            y(p) = y(q);
            BW(x(q)-1,y(q)) = 1;
        end
    end
    if y(q)+1 <= size(BW,2) 
        if BW(x(q),y(q)+1) == 0
            p = p+1;
            x(p) = x(q);
            y(p) = y(q)+1;
            BW(x(q),y(q)+1) = 1;
        end
    end
    if y(q)-1 >= 1 
        if BW(x(q),y(q)-1) == 0
            p = p+1;
            x(p) = x(q);
            y(p) = y(q)-1;
            BW(x(q),y(q)-1) = 1;
        end
    end
    q = q+1;
end
subplot(3,3,3); imshow(BW)


%== Step 3: Rolling Ball Transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
se = strel('disk',round(a*minparticlesize/npix));
img_bewBW = imclose(BW,se);
subplot(3,3,4); imshow(img_bewBW)

se = strel('disk',round(b*minparticlesize/npix));
img_bewBW = imopen(img_bewBW,se);
subplot(3,3,5); imshow(img_bewBW)

se = strel('disk',round(c*minparticlesize/npix));
img_bewBW = imclose(img_bewBW,se);
subplot(3,3,6); imshow(img_bewBW)

se = strel('disk',round(d*minparticlesize/npix));
img_bewBW = imopen(img_bewBW,se);
subplot(3,3,7); imshow(img_bewBW)


%== Step 4: Delete blobs under a threshold area size =====================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
for kk = 1:nparts
    area_aggregate = length(CC.PixelIdxList{1,kk})*npix^2;
    
    if area_aggregate <= (e*minparticlesize/npix)^2 && moreaggs == 0
        img_bewBW(CC.PixelIdxList{1,kk}) = 1;
    end
end
subplot(3,3,8); imshow(img_bewBW)

img_edge = edge(img_bewBW,'sobel');
se_edge = strel('disk',1);
img_dilatededge = imdilate(img_edge,se_edge);
clear Edge_Image0 SE2
img_finalimposed = imimposemin(img_cropped, img_dilatededge);
figure; imshow(img_finalimposed);


%== Step 5: User interaction =============================================%
 choice = questdlg('Satisfied with automatic aggregate detection? You will be able to delete non-aggregate noises and add missing particles later. If not, other methods will be used',...
     'Agg detection','Yes','Yes, but reduce noise','No','Yes'); 

if strcmp(choice,'Yes')
    img_binary = img_bewBW;
elseif strcmp(choice,'Yes, but reduce noise')
    % to further reduce the noise, and solve the area calculation problems
    % of images with multiple particles
    uiwait(msgbox('Please selects (left click) particles satisfactorily detected and press enter'));
    img_binary_int = bwselect(~img_bewBW,8);
    img_binary = ~img_binary_int;
elseif strcmp(choice,'No') % semi-automatic or manual methods will be used
    img_binary = [];
    moreaggs = 1;
end

end
