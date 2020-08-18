
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
if ~exist('bool_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 0; end

if ~exist('bool_backup','var'); f_backup = []; end
if isempty(f_backup); f_backup = 0; end

disp('Performing PCM analysis...');

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


%-- Check whether the data folder is available ---------------------------%
if exist('data','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('data') % make output folder
end


if f_plot; figure; end % generate figure for visualizing current aggregate


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
    Skel = bwmorph(img_binary,'thin',Inf);
    [skeletonY, skeletonX] = find(Skel);
    
    %-- 3-3-2: Calculate the distances between skeleton pixels and other pixels
    [row, col] = find(img_binary);
    
    % to consolidate the pixels of consideration to much smaller arrays
    p       = 0;
    X       = 0;
    Y       = 0;
    density = 20; % larger densities make the program less computationally expensive

    for kk = 1:density:data.num_pixels
        p    = p + 1;
        X(p) = col(kk);
        Y(p) = row(kk);
    end

    % To calculate all the distances with reference to one pixel at a time,
    % using vector algebra, and then adding the results.
    dist_mat = []; % reinitialize dist_mat
    for kk = 1:1:length(skeletonX)
        Distance_int = ((X-skeletonX(kk)).^2+(Y-skeletonY(kk)).^2).^.5;
        dist_mat(((kk-1)*length(X)+1):(kk*length(X))) = Distance_int;
    end

    %-- 3-3-3: Construct the pair correlation ------------------------%
    %   Sort radii into bins and calculate PCF
    dist_max = double(uint16(max(dist_mat)));
    dist_mat = nonzeros(dist_mat).*pixsize;
    nbins        = dist_max * pixsize; % number of radius bins
    dr           = 1; % interval for radius vector, below
    r            = 1:dr:nbins; % radius
    
    % Pair correlation function (PCF)
    % PCF = histcounts(Distance_mat,[Radius-dr/2,Radius(end)+dr/2]);
    pcf = hist(dist_mat, r); % UPDATE REMOVED

    % Smoothing the pair correlation function (PCF)
    % Updated to remove number of variables
    d                          = 5 + 2 * dist_max;
    bw                         = zeros(d,d);
    bw(dist_max+3, dist_max+3) = 1;
    bw                         = bwdist(bw, 'euclidean');
    bw                         = bw./dist_max;
    bw                         = im2bw(bw,1);
    
    
    %-- Prep for PCM -----------------------------------------------------%
    [row, col] = find(~bw); % find non-zero pixels in binary
    dist_denominator = ((row-dist_max+3).^2+(col-dist_max+3).^2).^.5;
    dist_denominator = nonzeros(dist_denominator) .* pixsize;
    % Denamonator = histcounts(Distance_Denaminator,[Radius-dr/2,Radius(end)+dr/2]);
    denominator = hist(dist_denominator, r); % UPDATE REMOVED
    denominator = denominator .* length(skeletonX) ./ density;
    denominator(denominator==0) = 1; % bug fix, overcomes division by zero
    pcf = pcf ./ denominator; % update pair correlation function
    pcf_smooth = smooth(pcf); % smooth the pair correlation function

    for kk=1:size(pcf_smooth)-1
        if pcf_smooth(kk) == pcf_smooth(kk+1)
            pcf_smooth(kk+1) = pcf_smooth(kk) - 1e-4;
        end
    end
    %{
    % UPDATE REMOVED
    [~,ia] = unique(PCF_smoothed); % bug fix, remove non-unique entries
    ia = sort(ia);
    PCF_smoothed = PCF_smoothed(ia);
    Radius = Radius(ia);
    %}
    
    %== 3-5: Primary particle sizing =====================================%
    %-- 3-5-1: Simple PCM ------------------------------------------------%
    pcf_simple   = .913;
    Aggs(ll).dp_pcm_simple = ...
        2*interp1(pcf_smooth, r, pcf_simple);
        % dp from simple PCM
    
    %-- 3-5-2: Generalized PCM ---------------------------------------%
    Rg_u     = 1.1 * data.Rg; % 10% higher than Rg
    Rg_l     = 0.9 * data.Rg; % 10% lower than Rg
    pcf_Rg   = interp1(r, pcf_smooth, data.Rg); % P at Rg
    pcf_Rg_u = interp1(r, pcf_smooth, Rg_u); % P at upper Rg
    pcf_Rg_l = interp1(r, pcf_smooth, Rg_l); % P at lower Rg
    PRgslope = (pcf_Rg_u+pcf_Rg_l-pcf_Rg)/(Rg_u-Rg_l); % dp/dr(Rg)

    pcf_general = (.913/.84)*...
        (0.7+0.003*PRgslope^(-0.24)+0.2*data.aspect_ratio^-1.13);
    Aggs(ll).dp_pcm_general = ...
        2*interp1(pcf_smooth, r, pcf_general);
        % dp from generalized PCM
    
        
    %-- Plot pair correlation function in line graph format ----------%
    if f_plot
        str = sprintf('Pair Correlation Line Plot %f ',pcf_simple);
        figure, loglog(r, smooth(pcf), '-r'),...
            title (str), xlabel ('Radius'), ylabel('PCF(r)')
        hold on;
        loglog(Aggs(ll).pcm_dp_simple,pcf_simple,'*')
        close all;
    end
    

    %== Step 4: Save results =========================================%
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
