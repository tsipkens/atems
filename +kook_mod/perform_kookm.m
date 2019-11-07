
% PERFORM_KM  Performs modified Kook algorithm
%
% Code written by Ben Gigone and Emre Karatas, PhD
% Adapted from Kook et al. 2016, SAE
% Works on Matlab 2012a or higher + Image RawImage Toolbox
%
% This code is modified by Yiling Kang, Timothy Sipkens, and
% Yeshun (Samuel) Ma at the University of British Columbia
%
% Check README.txt file for more documentation and information
%=========================================================================%

function Aggs = perform_km(Aggs,bool_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end

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


%== Main image processing loop ===========================================%
for ll = 1:length(Aggs) % run loop as many times as images selected

    %-- Crop footer and get scale --------------------------------------------%
    pixsize = Aggs(ll).pixsize; 
    img_cropped = Aggs(ll).img_cropped;
    img_binary = Aggs(ll).img_cropped_binary;
    
    %if bool_plot
        figure(gcf); imshow(img_cropped);
    %end
    
    %-- Creating a new folder to store data from this image processing program --%
    % TODO : Add new directory folder for each image and input overlayed image,
    % original image, edge detection results, and histogram for each one
    
    
    %== Begin image processing ===========================================%
    [img_Canny,Data] = kook_mod.preprocess(img_cropped,img_binary);
    Data.method = 'kook_mod';
    
    
    %== Find and draw circles within aggregates ==========================%
    % Find circles within soot aggregates 
    [centers, radii] = imfindcircles(img_Canny,[rmin rmax],...
        'ObjectPolarity', 'bright', 'Sensitivity', sens_val, 'Method', 'TwoStage'); 
    Data.centers = centers;
    Data.radii = radii;
    
    
    % Draw circles (Figure 7)
    figure();
    imshow(img_cropped,[]);
    hold on;
    h = viscircles(centers, radii, 'EdgeColor','r');
    hold off;
    title('Step 7: Parimary particles overlaid on the original TEM image');
    pause(0.2);

    %-- Check the circle finder by overlaying the CHT boundaries on the original image 
    %-- Remove circles out of the aggregate (?)
    R = imfuse(img_Canny,img_cropped,'blend'); 

    % Draw modified circles (Figure 8)
    if bool_plot
        figure();imshow(R,[],'InitialMagnification',500);hold;h = viscircles(centers, radii, 'EdgeColor','r'); 
        title('Step 8: Primary particles overlaid on the Canny edges and the original TEM image');
        saveas(gcf, [folder_save_img,'\circAll_',int2str(ll)], 'tif')
    end


    %-- Calculate Parameters (Add Histogram) -----------------------------%
    Data.dp = radii*pixsize*2;
    Data.dpg = nthroot(prod(Data.dp),1/length(Data.dp)); % geometric mean
    Data.sg = log(std(Data.dp)); % geometric standard deviation
    
    Data.Np = length(Data.dp); % number of particles
    
    if bool_plot
        figure();
        imshow(img_binary, []);
        title('Image Binarized'); 
        text(0.25 * size(img_binary, 1), 0.1 * size(img_binary, 2), sprintf('Radius of gyration = %6.2f nm', (Data.Rg)),...
            'fontsize', 12, 'fontname','TimesNewRoman');
    end
    
    %== Save results =====================================================%
    %   Format output and autobackup data --------------------------------%
    Aggs(ll).kook_mod = Data; % copy data structure into img_data
    if mod(ll,10)==0 % save data every 10 aggregates
        disp('Saving data...');
        save(['data',filesep,'kook_mod_data.mat'],'Aggs'); % backup img_data
        disp('Save complete');
        disp(' ');
    end
    close all;
    
end % end of aggregate loop

disp('Complete.');
disp(' ');

end
