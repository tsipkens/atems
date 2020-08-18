
% PCM  Performs the pair correlation method (PCM) of aggregate characterization
% 
% Developed at the University of British Columbia by Ramin Dastanpour and
% Steven N. Rogak.
%
% Image processing package for the analysis of TEM images. Automatic
% Aggsregate detection and automatic primary particle sizing
%
% This code was more recently modified by Timothy Sipkens at the University
% of British Columbia
%=========================================================================%

function [Aggs] = pcm(Aggs, f_plot, f_backup)

%-- Parse inputs and load image ------------------------------------------%
% Choose whether to plot pair correlation functions (PCFs).
if ~exist('bool_plot','var'); f_plot = []; end 
if isempty(f_plot); f_plot = 0; end

% Choose whether to save backup copies during evaluation to temp/ folder.
if ~exist('bool_backup','var'); f_backup = []; end
if isempty(f_backup); f_backup = 0; end

% if isstruct(aggs)
%     Aggs_str = aggs;
%     aggs = {Aggs_str.Cropped};
%     pixsize = [Aggs_str.pixsize];
%     fname = {Aggs_str.fname};
% elseif ~iscell(aggs)
%     aggs = {aggs};
% end
% 
% if ~exist('pixsize','var'); pixsize = []; end
% if isempty(pixsize); pixsize = ones(size(aggs)); end
%-------------------------------------------------------------------------%


disp('Performing PCM analysis...');


%-- Check whether the data folder is available ---------------------------%
if exist('data','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('data') % make output folder
end


figure; % generate figure for visualizing current aggregate


%== Main image processing loop ===========================================%
n_aggs = length(Aggs);
tools.textbar(0);

for ll = 1:n_aggs % loop over each aggregate in the provided structure
    
    %== Step 1: Image preparation ========================================%
    pixsize = Aggs(ll).pixsize; % size of pixels in the image
    img_binary = Aggs(ll).img_cropped_binary; % get the binarized image for this aggregate
    
    %-- Loop through aggregates ------------------------------------------%
    data = Aggs(ll); % initialize data structure for current aggregate
    data.method = 'pcm';
    
    
    
    %== Step 3-3: Development of the pair correlation function (PCF) -%
    %-- 3-3-1: Find the skeleton of the aggregate --------------------%
    skel = bwmorph(img_binary, 'thin', Inf); % get aggregate skeleton
    [skel_y, skel_x] = find(skel); % find skeleton pixels
    
    
    %-- 3-3-2: Calculate the distances between binary pixels
    [row, col] = find(img_binary);
    
    % To consolidate the pixels of consideration to much smaller arrays, we
    % apply thinning, which makes the program less computationally
    % expensive. Thinning aims for a vector of max length of 3,000. 
    thin = max(round(data.num_pixels/6e3), 1);
    X = col(1:thin:data.num_pixels);
    Y = row(1:thin:data.num_pixels);
    
    % To calculate all the distances with reference to one pixel at a time,
    % using vector algebra, and then adding the results.
    d_vec = sqrt((X - skel_x') .^2 + (Y - skel_y') .^2);
    d_vec = nonzeros(d_vec(:)'); % vectorize the output and remove zeros
    
    
    %-- 3-3-3: Construct the pair correlation ----------------------------%
    %   Sort radii into bins and calculate PCF
    d_max = double(uint16(max(d_vec))); % maximum distance in px
    d_vec = d_vec .* pixsize; % vector of distances in nm
    r     = 1:1:(d_max * pixsize); % radius vector in nm
    
    % Pair correlation function (PCF)
    pcf = histcounts(d_vec, [r-1/2,r(end)+1/2]); % updated call (last entry is different)
    idx_p = find(pcf~=0); pcf = pcf(idx_p); % remove zero PCFs
    r1 = r(idx_p); % radius, adjusted for zero PCFs
    
    % Smoothing the pair correlation function (PCF
    % Updated to remove number of variables
    d   = 5 + 2 * d_max;
    bw  = zeros(d, d);
    bw(d_max + 3, d_max + 3) = 1;
    bw  = bwdist(bw, 'euclidean');
    bw  = bw ./ d_max;
    bw  = im2bw(bw, 1);
    
    %-- Prep for PCM -----------------------------------------------------%
    [row, col] = find(~bw); % find non-zero pixels in binary
    d_denominator = sqrt((row - d_max + 3) .^2 + (col - d_max + 3) .^2);
    d_denominator = nonzeros(d_denominator) .* pixsize;
    
    denominator = histcounts(d_denominator, [r-1/2, r(end)+1/2]);
    denominator = denominator(idx_p) .* length(skel_x) ./ thin;
    denominator(denominator==0) = 1; % bug fix, overcomes division by zero
    pcf = pcf ./ denominator; % update pair correlation function
    pcf_smooth = smooth(pcf); % smooth the pair correlation function
    
    % adjust PCF to be monotonically decreasing
    for kk=1:(size(pcf_smooth)-1)
        if pcf_smooth(kk) <= pcf_smooth(kk+1)
            pcf_smooth(kk+1) = pcf_smooth(kk) - 1e-12;
        end
    end
    pcf_smooth = pcf_smooth ./ max(pcf_smooth); % normalize by initial value
    
    
    
    %== 3-5: Primary particle sizing =====================================%
    %-- 3-5-1: Simple PCM ------------------------------------------------%
    pcf_simple = 0.913;
    Aggs(ll).dp_pcm_simple = ...
        2 * interp1(pcf_smooth, r1, pcf_simple);
        % dp from simple PCM
        % given by diameter corresponding to 91.3% of PCF
    
        
    %-- 3-5-2: Generalized PCM -------------------------------------------%
    Rg_u     = 1.1 * data.Rg; % perturb Rg, 10% higher
    Rg_l     = 0.9 * data.Rg; % perturb Rg, 10% lower
    pcf_Rg   = interp1(r1, pcf_smooth, data.Rg); % PCF at Rg
    pcf_Rg_u = interp1(r1, pcf_smooth, Rg_u); % PCF at upper Rg
    pcf_Rg_l = interp1(r1, pcf_smooth, Rg_l); % PCF at lower Rg
    Rg_slope = (pcf_Rg_u + pcf_Rg_l - pcf_Rg) / (Rg_u - Rg_l);
        % dp/dr(Rg), slope by finite difference

    pcf_general = (0.913 / 0.84) * ...
        (0.7 + 0.003*Rg_slope^-0.24 + 0.2*data.aspect_ratio^-1.13);
    Aggs(ll).dp_pcm_gen = ...
        2 * interp1(pcf_smooth, r1, pcf_general);
        % dp from generalized PCM
       
        
    %-- Plot pair correlation function in line graph format --------------%
    if f_plot
        str = sprintf('Pair Correlation Line Plot %f ', pcf_simple);
        figure, loglog(r, smooth(pcf), '-r'),...
            title (str), xlabel ('Radius'), ylabel('PCF(r)')
        hold on;
        loglog(Aggs(ll).pcm_dp_simple, pcf_simple,'*')
        close all;
    end
    
    

    %== Step 4: Save results =============================================%
    %   Autobackup data (every ten particles)
    if f_backup==1
        if mod(ll,10)==0
            disp('Saving data...');
            save(['temp',filesep,'pcm_data.mat'],'Aggs'); % backup img_data
            disp('Complete.');
            tools.textbar(0); % reinitilize space for textbar
        end
    end
    
    tools.textbar(ll / n_aggs);
end

close; % close current figure

disp('Complete.');
disp(' ');

end
