
% KOOK2  Performs modified Kook algorithm that considers aggregate binaries.
%
% Original code written by Ben Gigone and Emre Karatas, PhD
% Adapted from Kook et al. 2016, SAE
% Works on Matlab 2012a or higher + Image RawImage Toolbox
%
% This code was modified by Yiling Kang and Timothy Sipkens
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
% can be adjusted to filter out outliers in line 31-32 with rmax and rmin.
% 
%=========================================================================%

function Aggs = kook2(Aggs, f_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('f_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end

disp('Performing modified Kook:');


%-- Sensitivity and Scaling Parameters -----------------------------------%
max_img_count = 255; % Maximum image count for 8-bit image 
self_subt = 0.8; % Self-subtraction level 
mf = 1; % Median filter [x x] if needed 
alpha = 0.1; % Shape of the negative Laplacian "unsharp" filter 0->1 0.1
rmax = 30; % Maximum radius in pixel
rmin = 6; % Minimum radius in pixel (Keep high enough to eliminate dummies)
sens_val = 0.75; % the sensitivity (0?1) for the circular Hough transform 


if f_plot==1; f0 = figure; end

%== Main image processing loop ===========================================%
% Prepare for loop over image indexes.
idx = unique([Aggs.img_id]); % unique image indexes
n_imgs = length(idx);

n_aggs = length(Aggs); % total number of aggregates
tools.textbar(0);

for ii = 1:n_imgs % run loop as many times as images selected
    
    idx0 = [Aggs.img_id]==idx(ii);
    idx_agg = 1:length(Aggs);
    idx_agg = idx_agg(idx0);
    a1 = idx_agg(1);
    
    if f_plot==1; tools.imshow(Aggs(a1).image); drawnow; end
    
    %-- Crop footer and get scale ----------------------------------------%
    pixsize = Aggs(a1).pixsize; 
    img = Aggs(a1).image;
    
    
    %== Image preprocessing ==============================================%
    bg = self_subt .* img; % self-subtration from the original image
    img_bgs = max_img_count - img;
    img_bgs = img_bgs - bg; % subtract background
    
    img_medfilter = medfilt2(img_bgs, [mf, mf]); % median filterting to remove noise
    
    img_unsharp = imfilter(img_medfilter, fspecial('unsharp', alpha));
    
    img_canny = edge(img_unsharp, 'Canny'); % Canny edge detection
    
    % Imposing white background onto image. 
    % This prevents the program from detecting any background particles. 
    % img_canny = double(~img_binary) + double(img_canny0);
    %=====================================================================%
    
    
    %== Find and draw circles within aggregates ==========================%
    %   Find circles within soot aggregates 
    [centers, radii] = imfindcircles(img_canny, [rmin rmax],...
        'ObjectPolarity', 'bright', ...
        'Sensitivity', sens_val, 'Method', 'TwoStage'); 
    
    %-- Check the circle finder by overlaying boundaries on the original image
    if and(f_plot==1, ~isempty(centers))
        hold on;
        viscircles(centers, radii', 'EdgeColor', [0.1,0.1,0.1], ...
        	'LineWidth', 0.75, 'EnhanceVisibility', false);
        hold off;
        drawnow;
    end
    
    
    for aa=idx_agg % loop over aggregate for this image
        img_binary = Aggs(aa).binary;
        
        idx_s = sub2ind(size(img), round(centers(:,2)), round(centers(:,1)));
        in_aggregate = logical(img_binary(idx_s));
        
        idx_in = 1:length(idx_s);
        idx_in = idx_in(in_aggregate);
        
        Pp.centers = centers(idx_in,:);
        Pp.radii = radii(idx_in);

        %-- Calculate Parameters (Add Histogram) -----------------------------%
        Pp.dp = Pp.radii .* pixsize .* 2;
        Pp.dpg = nthroot(prod(Pp.dp), 1/length(Pp.dp)); % geometric mean
        Pp.sg = log(std(Pp.dp)); % geometric standard deviation

        Pp.Np = length(Pp.dp); % number of particles


        Aggs(aa).dp_kook = mean(Pp.dp);
        Aggs(aa).dp = mean(Pp.dp);
        Aggs(aa).Pp_kook = Pp; % copy primary particle information into Aggs
        
        %-- Check the circle finder by overlaying on the original image 
        %   Circles in blue if part of considered aggregates
        if and(f_plot==1, ~isempty(Pp.centers))
            hold on;
            viscircles(Pp.centers, Pp.radii', 'EdgeColor', [0.92,0.16,0.49], ...
                'LineWidth', 0.75, 'EnhanceVisibility', false);
            hold off;
            drawnow;
            pause(0.1);
        end
    end
    
    tools.textbar(ii / n_imgs);
    
end % end of image loop

dp = [Aggs.dp]; % compile dp output
close(f0);

disp('Complete.');
disp(' ');

end



