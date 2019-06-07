function Refined_surf_img = Background_fnc(binaryImage,Cropped_img)
% Semi-automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% This function smoothens background brightness, specially on the edges of
% the image where intensity (brightness) has a curved planar distribution.
% This improves thresholding in the following steps of image processing

%% Number of the pixels within the aggregate
Npix_agg = sum(sum(binaryImage));

%% Number of the pixels within the whole cropped image 
Npix_tot = size(Cropped_img,1)*size(Cropped_img,2);

%% Number of the pixels in the backgound of the aggregate
Npix_bckgrnd = Npix_tot-Npix_agg;

%% Computing average background intensity
burned_img = Cropped_img;
burned_img(binaryImage) = 0;
mean_bckgrnd =  mean(mean(burned_img))*Npix_tot/Npix_bckgrnd;

%% Replace aggregate pixels' intensities with the average value of the background intensity
Filled_img = Cropped_img;
Filled_img(binaryImage) = mean_bckgrnd;

%% Fitting a curved surface into Filled_img data
[x_d,y_d] = meshgrid(1:size(Filled_img,2),1:size(Filled_img,1));
xdata = {x_d,y_d};
fun = @(c,xdata) c(1).*xdata{1}.^2+c(2).*xdata{2}.^2+c(3).*xdata{1}.*xdata{2}+...
    c(4).*xdata{1}+c(5).*xdata{2}+c(6);

c_start=[0 0 0 0 0 mean_bckgrnd];
options = optimset('MaxFunEvals',1000);
options = optimset(options,'MaxIter',1000); 
[c] = lsqcurvefit(fun,c_start,xdata,double(Filled_img),[],[],options);

%% Building the fitted surface
for i=1:size(Filled_img,1)
    for j=1:size(Filled_img,2)
        fitted_surf(i,j)=c(1)*i^2+c(2)*j^2+c(3)*i*j+c(4)*i+c(5)*j+c(6);
    end
end

%% Refining Cropped_img, using fitted surface
refined_Surf_img_int=mean_bckgrnd+double(Cropped_img)-fitted_surf;
Refined_surf_img=uint8(refined_Surf_img_int);
