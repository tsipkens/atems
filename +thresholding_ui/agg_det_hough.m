
% AGG_DET_HOUGH  Hough Transformation and Rolling Ball Transformation
%                Automatic detection of the aggregates on TEM images
% Authors:  Ramin Dastanpour & Steven N. Rogak
% Notes:    Developed at the University of British Columbia
%           Last updated in Feb. 2016
%=========================================================================%

function [img_binary,moreaggs,choice] = ...
    agg_det_hough(img,npix,moreaggs,minparticlesize,coeffs,bool_plot) 

if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end


%== Step 1: Apply intensity threshold ====================================%
level = graythresh(img);
bw = imbinarize(img,level);
if bool_plot
    figure;
    hold on;
    subplot(3,3,1);imshow(img)
    subplot(3,3,2); imshow(bw)
end
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);


%== Step 2: Remove aggregates touching the edge of the image =============%
bw_edge = bw;
bw_edge(2:size(bw,1)-1,2:size(bw,2)-1) = 1;
[x,y] = find(bw_edge == 0);
p = length(x);
q = 1;
while q<=p
    if x(q)+1 <= size(bw,1)
        if bw(x(q)+1,y(q)) == 0
            p = p+1;
            x(p) = x(q)+1;
            y(p) = y(q);
            bw(x(q)+1,y(q)) = 1;
        end
    end
    if x(q)-1 >= 1 
        if bw(x(q)-1,y(q)) == 0
            p = p+1;
            x(p) = x(q)-1;
            y(p) = y(q);
            bw(x(q)-1,y(q)) = 1;
        end
    end
    if y(q)+1 <= size(bw,2) 
        if bw(x(q),y(q)+1) == 0
            p = p+1;
            x(p) = x(q);
            y(p) = y(q)+1;
            bw(x(q),y(q)+1) = 1;
        end
    end
    if y(q)-1 >= 1 
        if bw(x(q),y(q)-1) == 0
            p = p+1;
            x(p) = x(q);
            y(p) = y(q)-1;
            bw(x(q),y(q)-1) = 1;
        end
    end
    q = q+1;
end
if bool_plot; subplot(3,3,3); imshow(bw); end


%== Step 3: Rolling Ball Transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
disp('Morphologically closing image...');
se = strel('disk',round(a*minparticlesize/npix));
img_bewBW = imclose(bw,se);
if bool_plot; subplot(3,3,4); imshow(img_bewBW); end

disp('Morphologically opening image...');
se = strel('disk',round(b*minparticlesize/npix));
img_bewBW = imopen(img_bewBW,se);
if bool_plot; subplot(3,3,5); imshow(img_bewBW); end

disp('Morphologically closing image...');
se = strel('disk',round(c*minparticlesize/npix));
img_bewBW = imclose(img_bewBW,se);
if bool_plot; subplot(3,3,6); imshow(img_bewBW); end

disp('Morphologically opening image...');
se = strel('disk',round(d*minparticlesize/npix));
img_bewBW = imopen(img_bewBW,se);
if bool_plot; subplot(3,3,7); imshow(img_bewBW); end
disp('Completed morphological operations.');


%== Step 4: Delete blobs under a threshold area size =====================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
if nparts>50 % if a lot of particles, remove more particles
    mod = 10;
    disp(['Found too many particles, removing particles below: ',...
        num2str(e*10),' nm.']);
else
    mod = 1;
end
    
for kk = 1:nparts
    area = length(CC.PixelIdxList{1,kk})*npix^2;
    
    if area <= (mod*e*minparticlesize/npix)^2
        img_bewBW(CC.PixelIdxList{1,kk}) = 1;
    end
end
if bool_plot; subplot(3,3,8); imshow(img_bewBW); end

h = figure(gcf);
tools.plot_binary_overlay(img,img_bewBW);


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

close(h);

end
