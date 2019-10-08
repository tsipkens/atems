
% AGG_DET_KMEANS Hough Transformation and Rolling Ball Transformation
%                Automatic detection of the aggregates on TEM images
% Authors:  Timothy A. Sipkens
% Notes:    Developed at the University of British Columbia
%           Last updated in October 2019
%=========================================================================%

function [img_binary,moreaggs,choice] = ...
    agg_det_kmeans(img,pixsize,moreaggs,minparticlesize,coeffs) 


%-- Attempt to remove background gradient --------------------------------%
[X,Y] = meshgrid(1:size(img,2),1:size(img,1));
bg_fit = fit(double([X(:),Y(:)]),double(img(:)),'poly11');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(img)+t0;
t2 = t1-min(min(t1));
img = uint8(round(255.*t2./max(max(t2))));


%-- Get rough mask using thresholding ------------------------------------%
level = graythresh(img);
bw_thresh = 255.*imbinarize(img,level);

se = strel('disk',40);
bw_thresh2 = imopen(bw_thresh,se);


%-- Perform total variation denoising ------------------------------------%
N = size(img);
mu = 15;
disp('Performing total var. denoising...');
img_atv = reshape(...
    tools.tot_var_SB_ATV(double(img(:)),mu,N),N);
img_atv = uint8(img_atv);
disp('Complete.');
disp(' ');
% increases the interconnectedness when
%   combined with bottom hat and top hat


%-- Use morphological operations to improve kmeans -----------------------%
se = strel('disk',20);
img_bh = imbothat(img_atv,se);
img_th = imtophat(img_atv,se);
featureSet = cat(3,...
    repmat(bw_thresh2,[1,1,3]),... % aggregates disappear if too large
    repmat(img_bh,[1,1,3]),...
    repmat(img_th,[1,1,3]),... % expands aggregate slightly
    repmat(img_atv,[1,1,3]),...
    repmat(255-img_atv,[1,1,3]),...
    repmat(img,[1,1,0]),... % decreases interconnectedness
    repmat(255-img,[1,1,0])...
    ); % img2


%-- Perform kmeans segmentation ------------------------------------------%
bw = imsegkmeans(featureSet,2,'NormalizeInput',true);
bw = ~(bw==1);

[~,ind_min] = min([mean(img_atv(bw)),mean(img_atv(~bw))]);
bw = bw==(ind_min-1);



%== Step 2: Remove aggregates touching the edge of the image =============%
bw = ~imclearborder(~bw); % clear aggregates on border


%== Step 3: Rolling ball transformation ==================================%
%   imclose opens white areas
%   imopen opens black areas
a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);


disp('Morphologically closing image...');
se = strel('disk',round(a*minparticlesize/pixsize));
img_bewBW1 = imclose(bw,se);

disp('Morphologically opening image...');
se = strel('disk',round(b*minparticlesize/pixsize));
img_bewBW2 = imopen(img_bewBW1,se);

disp('Morphologically closing image...');
se = strel('disk',round(c*minparticlesize/pixsize));
img_bewBW3 = imclose(img_bewBW2,se);

disp('Morphologically opening image...');
se = strel('disk',round(d*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW3,se);
disp('Completed morphological operations.');


%== Step 4: Delete blobs under a threshold area size =====================%
CC = bwconncomp(abs(img_bewBW-1));
[~,nparts] = size(CC.PixelIdxList);
if nparts>25 % if a lot of particles, remove more particles
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

h = figure(gcf);
tools.plot_binary_overlay(img,img_bewBW);
f = gcf;
f.WindowState = 'maximized'; % maximize figure


%== Step 5: User interaction =============================================%
choice = questdlg('Satisfied with automatic aggregate detection? You will be able to delete non-aggregate noises and add missing particles later. If not, other methods will be used',...
     'Agg detection','Yes','Yes, but more particles?','No','Yes'); 

if strcmp(choice,'Yes')
    img_binary = img_bewBW;
elseif strcmp(choice,'Yes, but more particles?')
    img_binary = img_bewBW;
    moreaggs = 1;
elseif strcmp(choice,'No') % semi-automatic or manual methods will be used
    img_binary = [];
    moreaggs = 1;
end

close(h);

end
