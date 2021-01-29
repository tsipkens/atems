
% KOOK2  Performs modified Kook algorithm that considers aggregate binaries.
% 
%  [AGGS] = pp.kook2(AGGS) repackages the original code by Kook et al.
%  to work with the common data structures in this larger code. Uses the
%  individual aggregate information in AGGS to assign Hough transform
%  circles to individual aggregates and filters out background circles. 
%  
%  [AGGS] = pp.kook2(AGGS,F_PLOT) adds a flag for whether to produce a
%  plot of the primary particle sizes overlaid on the image for each
%  aggregate. By default, F_PLOT = 1 and the images will be plotted. Set
%  F_PLOT = 0 to speed execution. 
% 
%  [AGGS] = pp.kook2(AGGS,F_PLOT,OPTS) adds an options stucture to control
%  the algorithm. For defaults, see the "OPTIONS" section of the code below.
%  Note that if this argument is supplied, one must provide all seven
%  of the fields in the OPTS structure. Again, see the "OPTIONS"
%  section in the code below.
%
%  ------------------------------------------------------------------------
%  
%  This code was modified to provide more accurate primary particle size  
%  data with fuzzier and lower quality backgrounds. The code now saves the  
%  data as a MATLAB file. 
% 
%  Pre-processing steps are as follows:
%   1. Select individual particle to be processed.
%   2. Use a binary mask to assign primary particles to aggregates.
%   3. Bottom hat filter to fix background illumination and 
%      particle illumination. 
%   4. Enhance contrast between individual particles and betweent the 
%      agglomerate and background.
%   5. Median filter to remove salt and pepper noise from the particles 
%      and background.
% 
%  Canny edge detection sensitivity can be adjusted with the 
%  OPTS.edge_threshold parameter.
%  
%  Circular hough transform sensitivity can be adjusted with OPTS.sens_val 
%  of the code. In addition, the boundaries for the size of the circles 
%  detected can be adjusted to filter out outliers with OPTS.rmax 
%  and OPTS.rmin.
%  
%  Original code written by Ben Gigone and Emre Karatas, PhD.
%  Adapted from Kook et al. 2016, SAE.
%  Works on Matlab 2012a or higher + Image RawImage Toolbox. 
%  
%  This code was modified by Yiling Kang and Timothy Sipkens at the
%  University of British Columbia. 

function Aggs = kook2(Aggs, f_plot, opts)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('f_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end

tools.textheader('Performing Kook.v2 (Hough)');


%-- Sensitivity and Scaling Parameters -----------------------------------%
if ~exist('opts', 'var'); opts = []; end
if isempty(opts)
    opts.max_img_count = 255; % Maximum image count for 8-bit image 
    opts.self_subt = 0.8; % Self-subtraction level 
    opts.mf = 1; % Median filter [x x] if needed 
    opts.alpha = 0.1; % Shape of the negative Laplacian "unsharp" filter 0->1 0.1
    opts.rmax = 50; % Maximum radius in pixel
    opts.rmin = 8; % Minimum radius in pixel (Keep high enough to eliminate dummies)
    opts.sens_val = 0.75; % the sensitivity (0->1) for the circular Hough transform 
end


if f_plot==1; f0 = figure; end

%== Main image processing loop ===========================================%
% Prepare for loop over image indexes.
idx = unique([Aggs.img_id]); % unique image indexes
n_imgs = length(idx);

n_aggs = length(Aggs); % total number of aggregates
tools.textbar([0, n_imgs]);

for ii = 1:n_imgs % run loop as many times as images selected
    
    idx0 = [Aggs.img_id]==idx(ii);
    idx_agg = 1:length(Aggs);
    idx_agg = idx_agg(idx0);
    a1 = idx_agg(1);
    
    %-- Crop footer and get scale ----------------------------------------%
    pixsize = Aggs(a1).pixsize; 
    img = Aggs(a1).image;
    
    
    %== Image preprocessing ==============================================%
    bg = opts.self_subt .* img; % self-subtration from the original image
    img_bgs = opts.max_img_count - img;
    img_bgs = img_bgs - bg; % subtract background
    
    img_medfilter = medfilt2(img_bgs, [opts.mf, opts.mf]); % median filterting to remove noise
    
    img_unsharp = imfilter(img_medfilter, fspecial('unsharp', opts.alpha));
    
    img_canny = edge(img_unsharp, 'Canny'); % Canny edge detection
    
    % Imposing white background onto image. 
    % This would prevent the program from detecting any background
    % particles, but was found to be less useful in practice. 
    % img_canny = double(~img_binary) + double(img_canny0);
    %=====================================================================%
    
    
    %== Find and draw circles within aggregates ==========================%
    %   Find circles within soot aggregates 
    [centers, radii] = imfindcircles(img_canny, [opts.rmin opts.rmax],...
        'ObjectPolarity', 'bright', ...
        'Sensitivity', opts.sens_val, 'Method', 'TwoStage'); 
    
    %-- Check the circle finder by overlaying boundaries on the original image
    if and(f_plot==1, ~isempty(centers))
        tools.imshow(Aggs(a1).image); drawnow;
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
        Pp.dpm = mean(Pp.dp); % mean
        Pp.dpg = exp(mean(log(Pp.dp)));  % geometric mean
        Pp.sg = log(std(Pp.dp)); % geometric standard deviation

        Pp.Np = length(Pp.dp); % number of particles
        
        
        % Copy data to Aggs structure.
        Aggs(aa).Pp_kook = Pp; % copy primary particle information into Aggs
        Aggs(aa).dp_kook = Pp.dpg;  % goemetric mean
        Aggs(aa).dp = Pp.dpg;
        
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
    
    tools.textbar([ii, n_imgs]);
    
end % end of image loop

dp = [Aggs.dp]; % compile dp output
if f_plot==1; close(f0); end

tools.textheader();

end



