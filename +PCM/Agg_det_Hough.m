function [Binary_image,moreaggs,choice] = Agg_det_Hough(Cropped_img,pixsize,moreaggs,minparticlesize,coeffs) 
%% Hough Transformation and Rolling Ball Transformation
% Automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016

%% Step 1 Apply intensity threshold
level = graythresh(Cropped_img);
BW = im2bw(Cropped_img,level);
figure
hold on
subplot(3,3,1);imshow(Cropped_img)
subplot(3,3,2); imshow(BW)
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);

%% Step 2 Remove aggregates touching the edge of the image
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

%% Step 3 Rolling Ball Transformation
% imclose opens white areas
% imopen opens black areas
se = strel('disk',round(a*minparticlesize/pixsize));
NewBW = imclose(BW,se);
subplot(3,3,4); imshow(NewBW)

se = strel('disk',round(b*minparticlesize/pixsize));
NewBW = imopen(NewBW,se);
subplot(3,3,5); imshow(NewBW)

se = strel('disk',round(c*minparticlesize/pixsize));
NewBW = imclose(NewBW,se);
subplot(3,3,6); imshow(NewBW)

se = strel('disk',round(d*minparticlesize/pixsize));
NewBW = imopen(NewBW,se);
subplot(3,3,7); imshow(NewBW)

%% Step 4 Delete blobs under a threshold area size
CC = bwconncomp(abs(NewBW-1));
[~,numParts] = size(CC.PixelIdxList);
for k = 1:numParts
    area_pixelcount = length(CC.PixelIdxList{1,k});
    Aggregate_Area = area_pixelcount*pixsize^2;
    if Aggregate_Area <= (e*minparticlesize/pixsize)^2 && moreaggs == 0
        NewBW(CC.PixelIdxList{1,k}) = 1;
    end
end
subplot(3,3,8); imshow(NewBW)

Edge_Image = edge(NewBW,'sobel');
SE2 = strel('disk',1);
Dilated_Edge_Image = imdilate(Edge_Image,SE2);
clear Edge_Image0 SE2
FinalImposedImage = imimposemin(Cropped_img, Dilated_Edge_Image);
figure; imshow(FinalImposedImage);

%% Step 5 User interaction
 choice = questdlg('Satisfied with automatic aggregate detection? You will be able to delete non-aggregate noises and add missing particles later. If not, other methods will be used',...
     'Agg detection','Yes','Yes, but reduce noise','No','Yes'); 

if strcmp(choice,'Yes')
    Binary_image = NewBW;
elseif strcmp(choice,'Yes, but reduce noise')
    % to further reduce the noise, and solve the area calculation problems
    % of images with multiple particles
    uiwait(msgbox('Please selects (left click) particles satisfactorily detected and press enter'));
    Binary_int = bwselect(~NewBW,8);
    Binary_image = ~Binary_int;
elseif strcmp(choice,'No') % semi-automatic or manual methods will be used
    Binary_image = [];
    moreaggs = 1;
end
