
% PERFORM_PCM  Performs the pair correlation method (PCM) of aggregate characterization
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

function [Aggs] = perform_pcm(Aggs,bool_plot,bool_backup)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end

if ~exist('bool_backup','var'); bool_backup = []; end
if isempty(bool_backup); bool_backup = 0; end

disp('Performing PCM analysis...');

%-- Check whether the data folder is available ---------------------------%
if exist('data','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('data') % make output folder
end


figure; % generate figure for visualizing current aggregate


%== Main image processing loop ===========================================%
nAggs = length(Aggs);
tools.textbar(0);

for ll = 1:nAggs % run loop as many times as images selected
    
    %== Step 1: Image preparation ========================================%
    pixsize = Aggs(ll).pixsize;
    img_binary = Aggs(ll).img_cropped_binary;
    img_cropped = Aggs(ll).img_cropped;
    
    %-- Loop through aggregates ------------------------------------------%
    Data = Aggs(ll); % initialize data structure for current aggregate
    Data.method = 'pcm';
    
    figure(gcf);
    tools.plot_binary_overlay(img_cropped,img_binary); % show aggregate currently being analyzed
    
    
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

    for kk = 1:density:Data.num_pixels
        p    = p + 1;
        X(p) = col(kk);
        Y(p) = row(kk);
    end

    % to calculate all the distances with reference to one pixel at a time,
    % using vector algebra, and then adding the results
    Distance_mat = []; % reinitialize Distance_mat
    for kk = 1:1:length(skeletonX)
        Distance_int = ((X-skeletonX(kk)).^2+(Y-skeletonY(kk)).^2).^.5;
        Distance_mat(((kk-1)*length(X)+1):(kk*length(X))) = Distance_int;
    end

    %-- 3-3-3: Construct the pair correlation ------------------------%
    %   Sort radii into bins and calculate PCF
    Distance_max = double(uint16(max(Distance_mat)));
    Distance_mat = nonzeros(Distance_mat).*pixsize;
    nbins        = Distance_max * pixsize;
    dr           = 1;
    Radius       = 1:dr:nbins;
    
    % Pair correlation function (PCF)
    PCF = histcounts(Distance_mat,[Radius-dr/2,Radius(end)+dr/2]);
    % PCF = hist(Distance_mat,Radius);

    % Smoothing the pair correlation function (PCF)
    %   Updated to remove number of variables
    d                                  = 5 + 2*Distance_max;
    BW                                = zeros(d,d);
    BW(Distance_max+3,Distance_max+3) = 1;
    BW                                = bwdist(BW,'euclidean');
    BW                                = BW./Distance_max;
    BW                                = im2bw(BW,1);
    
    
    %-- Prep for PCM -----------------------------------------------------%
    [row,col] = find(~BW);
    Distance_Denaminator = ((row-Distance_max+3).^2+(col-Distance_max+3).^2).^.5;
    Distance_Denaminator = nonzeros(Distance_Denaminator).*pixsize;
    Denamonator = histcounts(Distance_Denaminator,[Radius-dr/2,Radius(end)+dr/2]);
    % Denamonator = hist(Distance_Denaminator,Radius);
    Denamonator = Denamonator.*length(skeletonX)./density;
    Denamonator(Denamonator==0) = 1; % bug fix, overcomes division by zero
    PCF = PCF./Denamonator;
    PCF_smoothed = smooth(PCF);

    for kk=1:size(PCF_smoothed)-1
        if PCF_smoothed(kk) == PCF_smoothed(kk+1)
            PCF_smoothed(kk+1) = PCF_smoothed(kk)-1e-4;
        end
    end
    
    [~,ia] = unique(PCF_smoothed); % bug fix, remove non-unique entries
    ia = sort(ia);
    PCF_smoothed = PCF_smoothed(ia);
    Radius = Radius(ia);
    
    %== 3-5: Primary particle sizing =====================================%
    %-- 3-5-1: Simple PCM ------------------------------------------------%
    PCF_simple   = .913;
    Aggs(ll).dp_pcm_simple = ...
        interp1(PCF_smoothed, Radius, PCF_simple);
        % dp from simple PCM
    
    %-- 3-5-2: Generalized PCM ---------------------------------------%
    URg      = 1.1*Data.Rg; % 10% higher than Rg
    LRg      = 0.9*Data.Rg; % 10% lower than Rg
    PCFRg    = interp1(Radius, PCF_smoothed, Data.Rg); % P at Rg
    PCFURg   = interp1(Radius, PCF_smoothed, URg); % P at URg
    PCFLRg   = interp1(Radius, PCF_smoothed, LRg); % P at LRg
    PRgslope = (PCFURg+PCFLRg-PCFRg)/(URg-LRg); % dp/dr(Rg)

    PCF_generalized   = (.913/.84)*(0.7+0.003*PRgslope^(-0.24)+0.2*Data.aspect_ratio^-1.13);
    Aggs(ll).dp_pcm_general = ...
        interp1(PCF_smoothed, Radius, PCF_generalized);
        % dp from generalized PCM
    
        
    %-- Plot pair correlation function in line graph format ----------%
    if bool_plot
        str = sprintf('Pair Correlation Line Plot %f ',PCF_simple);
        figure, loglog(Radius, smooth(PCF), '-r'),...
            title (str), xlabel ('Radius'), ylabel('PCF(r)')
        hold on;
        loglog(Aggs(ll).pcm_dp_simple,PCF_simple,'*')
        close all;
    end
    

    %== Step 4: Save results =========================================%
    %   Autobackup data (every ten particles)
    if bool_backup==1
        if mod(ll,10)==0
            disp('Saving data...');
            save(['data',filesep,'pcm_data.mat'],'Aggs'); % backup img_data
            disp('Complete.');
            tools.textbar(0); % reinitilize space for textbar
        end
    end
    
    tools.textbar(ll/nAggs);
    
end

close; % close current figure

disp('Complete.');
disp(' ');

end
