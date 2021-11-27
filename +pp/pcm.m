
% PCM  Performs the pair correlation method (PCM) of aggregate characterization
%  
%  Developed at the University of British Columbia by Ramin Dastanpour and
%  Steven N. Rogak.
%  
%  Image processing package for the analysis of TEM images. Automatic
%  Aggsregate detection and automatic primary particle sizing
%  
%  This code was more recently modified by Timothy Sipkens at the University
%  of British Columbia. 
%  
%  ------------------------------------------------------------------------
%  
%  VERSIONS: 
%    <strong>1.s</strong>: Default. Simple primary particle method. 
%         Normalize PCF by maximum. 
%    <strong>1.g</strong>: General primary particle method. 
%         Normalize PCF by maximum. 
%    <strong>0.s</strong>: Simple primary particle method. 
%         Normalize PCF according to original Dastanpour method. 

function [Aggs] = pcm(Aggs, f_plot, f_backup, opts)

%-- Parse inputs and load image ------------------------------------------%
% Choose whether to plot pair correlation functions (PCFs).
if ~exist('f_plot','var'); f_plot = []; end 
if isempty(f_plot); f_plot = 0; end

% Choose whether to save backup copies during evaluation to temp/ folder.
if ~exist('f_backup','var'); f_backup = []; end
if isempty(f_backup); f_backup = 0; end


%-- Handle options --%
default_opts = '+pp/config/pcm.v1.s.json';  % default, load this config file
if ~exist('opts', 'var'); opts = []; end  % if no opts specified
if isa(opts, 'char')  % if string, check if folder included
    if ~strcmp(opts(1:3), '+pp')
        opts = ['+pp/config/pcm.', opts, '.json'];
    end
end
opts = tools.load_config(opts, default_opts);
%-------------------------------------------------------------------------%


tools.textheader('PCM');

%-- Check whether the data folder is available ---------------------------%
if exist('data','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('data') % make output folder
end


figure; % generate figure for visualizing current aggregate


%== Main image processing loop ===========================================%
n_aggs = length(Aggs);

disp(' Characterizing aggregates:');
tools.textbar([0, n_aggs]);

for aa = 1:n_aggs % loop over each aggregate in the provided structure
    
    %== Step 1: Image preparation ========================================%
    pixsize = Aggs(aa).pixsize; % size of pixels in the image
    img_binary = imcrop(Aggs(aa).binary, Aggs(aa).rect); % get the binarized image for this aggregate
    
    % Get data for this aggregate
    data = Aggs(aa); % initialize data structure for current aggregate
    
    
    
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
    
    % Adjust PCF to be monotonically decreasing.
    for kk=1:(size(pcf_smooth)-1)
        if pcf_smooth(kk) <= pcf_smooth(kk+1)
            pcf_smooth(kk+1) = pcf_smooth(kk) - 1e-12;
        end
    end
    
    % Normalize by maximum, depending on options.
    if strcmp(opts.norm, 'max')
        pcf_smooth = pcf_smooth ./ max(pcf_smooth); % normalize by initial value
    end
    
    % If too small to have enough points to interpolated between.
    if length(pcf_smooth)==1
        Aggs(aa).dp_pcm1 = Aggs(aa).da;
        Aggs(aa).dp = Aggs(aa).dp_pcm1;
        continue;
    end
    
    
    %== 3-5: Primary particle sizing =====================================%
    %-- 3-5-1: Simple PCM ------------------------------------------------%
    if strcmp(opts.type, 'simple')
        pcf_simple = 0.913;
        Aggs(aa).dp_pcm = ...
            2 * interp1(pcf_smooth, r1, pcf_simple);
            % dp from simple PCM (labelled PCM1)
            % given by diameter corresponding to 91.3% of PCF

        % Catch case where particle is small and nearly spherical.
        % Otherwise NaN would be output.
        if and(and(isnan(Aggs(aa).dp_pcm), ...  % if previous method failed
                Aggs(aa).num_pixels<500), ...   % and small number of pixels
                Aggs(aa).aspect_ratio<1.4)  % and small aspect ratio
            Aggs(aa).dp_pcm = Aggs(aa).da;  % assign da to dp
        end

    %-- 3-5-2: Generalized PCM -------------------------------------------%
    else
        Rg_u     = 1.1 * data.Rg; % perturb Rg, 10% higher
        Rg_l     = 0.9 * data.Rg; % perturb Rg, 10% lower
        pcf_Rg   = interp1(r1, pcf_smooth, data.Rg); % PCF at Rg
        pcf_Rg_u = interp1(r1, pcf_smooth, Rg_u); % PCF at upper Rg
        pcf_Rg_l = interp1(r1, pcf_smooth, Rg_l); % PCF at lower Rg
        Rg_slope = (pcf_Rg_u + pcf_Rg_l - pcf_Rg) / (Rg_u - Rg_l);
            % dp/dr(Rg), slope by finite difference

        pcf_general = (0.913 / 0.84) * ...
            (0.7 + 0.003*Rg_slope^-0.24 + 0.2*data.aspect_ratio^-1.13);
        Aggs(aa).dp_pcm = ...
            2 * interp1(pcf_smooth, r1, pcf_general);
            % dp from generalized PCM (labelled PCM2)
    end
    
    Aggs(aa).dp = Aggs(aa).dp_pcm;  % assign main primary particle diameter and dp_pcm
       
        
    %-- Plot pair correlation function in line graph format --------------%
    if f_plot
        str = sprintf('Pair Correlation Line Plot %f ', pcf_simple);
        figure, loglog(r, smooth(pcf), '-r'),...
            title (str), xlabel ('Radius'), ylabel('PCF(r)')
        hold on;
        loglog(Aggs(aa).dp, pcf_simple,'*')
        close all;
    end
    
    

    %== Step 4: Save results =============================================%
    %   Autobackup data (every ten particles)
    if f_backup==1
        if mod(aa,10)==0
            disp(' Saving data ...');
            save(['temp',filesep,'pcm_data.mat'],'Aggs'); % backup img_data
            tools.textdone(2);
            tools.textbar(0); % reinitilize space for textbar
        end
    end
    
    tools.textbar([aa, n_aggs]);
end

close; % close current figure

tools.textheader();

end
