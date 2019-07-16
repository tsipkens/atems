%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

%% Applying this function smoothens background brightness,
%  specially on the edges of the image where intensity deflects from tilted
%  into curved planar distribution. This improves thresholding in the next
%  step of image processing

function [Refined_surf_im] = Background_fun(binaryImage,Cropped_im)

%% Number of the pixels within the aggregate
N_ag = sum(sum(binaryImage));

%% Number of the pixels within the whole cropped image 
N_tot = size(Cropped_im,1)*size(Cropped_im,2);

%% Number of the pixels in the backgound of the aggregate
N_b = N_tot-N_ag;

%% Computing the background average intensity
burned_im = Cropped_im;
burned_im(binaryImage) = 0;
mean_burned_im = mean(mean(burned_im));
mean_b = mean_burned_im*N_tot/N_b;

%% Replace aggregate pixels intensity with the average value of the background
Filled_im = Cropped_im;
Filled_im(binaryImage) = mean_b;

%% Fitting a curved surface into Filled_im data
[x_d,y_d] = meshgrid(1:size(Filled_im,2),1:size(Filled_im,1));
xdata = {x_d,y_d};
fun = @(c,xdata) c(1).*xdata{1}.^2+c(2).*xdata{2}.^2+c(3).*xdata{1}.*xdata{2}+...
    c(4).*xdata{1}+c(5).*xdata{2}+c(6);

c_start=[0 0 0 0 0 mean_b];
options = optimset('MaxFunEvals',1000);
options = optimset(options,'MaxIter',1000); 
[c] = lsqcurvefit(fun,c_start,xdata,double(Filled_im),[],[],options);

%% Building the fitted surface
for i=1:size(Filled_im,1)
    for j=1:size(Filled_im,2)
        fitted_surf(i,j)=c(1)*i^2+c(2)*j^2+c(3)*i*j+c(4)*i+c(5)*j+c(6);
    end
end

%% Refining Cropped_im, using fitted surface
refined_Surf_im_d=mean_b+double(Cropped_im)-fitted_surf;
Refined_surf_im=uint8(refined_Surf_im_d);
