
% KOOK_YL  Performs modified Kook algorithm
%
% Code written by Ben Gigone and Emre Karatas, PhD
% Adapted from Kook et al. 2016, SAE
% Works on Matlab 2012a or higher + Image RawImage Toolbox
%
% This code is modified by Yiling Kang
% 
% Compatability updates by Timothy Sipkens and
% Yeshun (Samuel) Ma at the University of British Columbia
% 
%-------------------------------------------------------------------------%
%
% This code was modified to provide more accurate primary particle size data with
% fuzzier and lower quality backgrounds. The code now saves the data as a MATLAB 
% file. This needs to be updated to output the different processing steps.
% 
% Pre-processing steps are as follows:
% 1. Select individual particle to be processed
% 2. Use thresholding method adapted from Dastanpour et al. 2016 to extract binary
%    image from particle
% 3. Bottom hat filter to fix background illumination and particle illumination
% 4. Enhance contrast between individual particles and betweent the agglomerate and
%    background
% 5. Median filter to remove salt and pepper noise from the particles and background
% 6. Save results of pre-processing into new folder for image
% 
% Processing steps are then as follows:
% 1. Multiply binary image by grayscale image to delete the background (replace
%    with 0/black pixels)
% 2. Canny edge detection* to detect the edge of the individual particle circles
% 3. Imposing white background onto image so the program does not detect any
%    background particles.
% 4. Use imfindcircles/circular hough transform** to detect circles from image. Use
%    the 'dark' setting to detect dark cirlces only, and not the background
% 5. Save image results
% 6. Calculate size of circles and save data into Excel
% 
% Canny edge detection sensitivity can be adjusted with the edge_threshold
% parameter in line 34 of the program
% 
% Circular hough transform sensitivity can be adjusted with sens_val in line 33
% of the code. In addition, the boundaries for the size of the circles detected
% can be adjusted to filter out outliers in line 31-32 with rmax and rmin
%=========================================================================%

function Aggs = kook_yl(Aggs,dp,f_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 0; end

disp('Performing modified Kook analysis...');

%-- Check whether the data folder is available ---------------------------%
if exist('data','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('data') % make output folder
end


%-- Sensitivity and Scaling Parameters -----------------------------------%
maximgCount = 255; % Maximum image count for 8-bit image 
SelfSubt = 0.8; % Self-subtraction level 
mf = 1; % Median filter [x x] if needed 
alpha = 0.1; % Shape of the negative Laplacian â€œunsharpâ€? filter 0->1 0.1
rmax = 30; % Maximum radius in pixel
rmin = 4; % Minimum radius in pixel (Keep high enough to eliminate dummies)
sens_val = 0.75; % the sensitivity (0?1) for the circular Hough transform 
edge_threshold = [0.125 0.190]; % the threshold for finding edges with edge detection

if f_plot>=1; figure(1); imshow(Aggs(1).image); end

%== Main image processing loop ===========================================%
for ll = 1:length(Aggs) % run loop as many times as images selected

    %-- Crop footer and get scale --------------------------------------------%
    pixsize = Aggs(ll).pixsize; 
    img_cropped = Aggs(ll).img_cropped;
    img_binary = Aggs(ll).img_cropped_binary;
    
    
    %-- Creating a new folder to store data from this image processing program --%
    % TODO : Add new directory folder for each image and input overlayed image,
    % original image, edge detection results, and histogram for each one
    
    
    %== Begin image processing ===========================================%
    [img_canny, Data] = preprocess(img_cropped,img_binary);
    Data.method = 'kook_mod';
    
    
    %== Find and draw circles within aggregates ==========================%
    % Find circles within soot aggregates 
    [centers, radii] = imfindcircles(img_canny,[rmin rmax],...
        'ObjectPolarity', 'bright', 'Sensitivity', sens_val, 'Method', 'TwoStage'); 
    Data.centers = centers;
    Data.radii = radii;
    
    %-- Calculate Parameters (Add Histogram) -----------------------------%
    Data.dp = radii*pixsize*2;
    Data.dpg = nthroot(prod(Data.dp),1/length(Data.dp)); % geometric mean
    Data.sg = log(std(Data.dp)); % geometric standard deviation
    
    Data.Np = length(Data.dp); % number of particles
    
    %-- Check the circle finder by overlaying the CHT boundaries on the original image 
    %-- Remove circles out of the aggregate (?)
    if and(f_plot>=1,~isempty(centers))
        figure(1);
        hold on;
        viscircles(centers+repmat(Aggs(ll).rect([1,2]),[size(centers,1),1]), ...
            radii', 'EdgeColor','r');
        hold off;
    end
    
    %== Save results =====================================================%
    %   Format output and autobackup data --------------------------------%
    Aggs(ll).kook_mod = Data; % copy data structure into img_data
    Aggs(ll).dp = Data.dp;
    if mod(ll,10)==0 % save data every 10 aggregates
        disp('Saving data...');
        save(['data',filesep,'kook_mod_data.mat'],'Aggs'); % backup img_data
        disp('Save complete');
        disp(' ');
    end
    
end % end of aggregate loop

dp = [Aggs.dp]; % compile dp output

disp('Complete.');
disp(' ');

end



%== PREPROCESS ===========================================================%
%   Perform preprocessing of image.
%   Author:       Timothy Sipkens, 2019-06-24; Yiling Kang, 2018
%   Originally:   Ben Gigone and Emre Karatas, PhD
%   Citations:    Kook et al. 2016, SAE
%
% Preprocesses the cropped aggregate using background subtraction and
% various techniques.  Works on one aggregate.
%
% Parameters:   agg_cropped - cropped image of aggregate
%               agg_binary - cropped binary image of aggregate

function [img_Canny,Data] = ...
    preprocess(img_cropped,img_binary)


%-- Fix background illumination ------------------------------------------%
se = strel('disk',85);
Data.img_bothat = imbothat(img_cropped,se);


%-- Enhance Contrast -----------------------------------------------------%
Data.img_contrast = imadjust(Data.img_bothat);


%-- Median Filtering -----------------------------------------------------%
%   Step 3: median filter to remove noise 
Data.img_medfilter = medfilt2(Data.img_contrast); %, [mf mf]); 

    
%== RawImage processing ==================================================%
%   Background erasing, Canny edge detection, background inversion, 
%   Circular Hough Transform

%-- Erasing background by multiplying binary image with grayscale image --%
Data.img_analyze = uint8(img_binary).*Data.img_medfilter ;


%-- Canny Edge Detection -------------------------------------------------%
img_Canny0 = edge(Data.img_analyze,'Canny'); % MATLAB Canny edge detection


%-- Imposing white background onto image ---------------------------------%
%   This prevents the program from detecting any background particles
img_Canny = double(~img_binary) + double(img_Canny0);
Data.img_Canny = img_Canny;

end


