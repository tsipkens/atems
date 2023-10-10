
% EDM_WS  Performs Euclidean distance mapping and watershed analyses
% Adapted from the work of De Temmerman et al., Powder Technol. (2014).
% Author: Timothy Sipkens, 2020-12-94
% 
% 
% INPUTS: 
%   imgs_Aggs    Could be one of three options: 
%                (1) An Aggs structure, produced by other parts of this program
%                (2) A single binary image, where 1s indicate aggregate.
%                (3) A cellular arrays of the above images.
%   pixsizes     A scalar or vector contain the pixel size for each image.
%                (Not used if an Aggs structure is provided.)
% 
% OUTPUTS: 
%   Aggs         A structure containing information for each aggregate.
%=========================================================================%

function [Aggs] = edm_ws(imgs_Aggs, pixsizes, f_plot)


%-- Parse inputs ---------------------------------------------------------%
% OPTION 1: Consider case that Aggs is given as input.
if isstruct(imgs_Aggs)
    Aggs0 = imgs_Aggs;
    pixsizes = [Aggs0.pixsize];
    imgs_binary = {Aggs0.binary};
    Aggs = Aggs0;

% OPTION 2: A single binary image is given.
elseif ~iscell(imgs_Aggs)
    imgs_binary = {imgs_Aggs};
    Aggs = struct([]); % initialize Aggs structure
    
% OPTION 3: A cellular array of images is given.
else
    Aggs = struct([]); % initialize Aggs structure
    
end

% Extract or assign the pixel size for each aggregate
if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = 1; end
if length(pixsizes)==1; pixsizes = pixsizes.*ones(size(imgs_binary)); end

if ~exist('f_plot', 'var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end
%-------------------------------------------------------------------------%


tools.textheader('EDM-Watershed (EDM-WS)');

% Create plot and associated variables.
if f_plot==1
    f0 = figure;
    cm = [0,0,0;spring];
    f0.WindowState = 'maximized';
end

%-- Main loop over binary images -----------------------------------------%
disp(' Characterizing aggregates:');
tools.textbar([0, length(imgs_binary)]);

for aa=1:length(imgs_binary)  % loop over aggregates
    
    % If new image, plot the image.
    if f_plot==1
        subplot(1,2,1);
        if aa==1
            tools.imshow(Aggs(aa).image); drawnow;
        elseif ~(Aggs(aa).img_id==Aggs(aa-1).img_id)
            tools.imshow(Aggs(aa).image); drawnow;
        end
        
        ax = subplot(1,2,2);
    end

    img_binary = imgs_binary{aa};
    pixsize = pixsizes(aa);

    
    %-- Compute Eucldian distance map ------------------------------------%
    img_edm = bwdist(~full(img_binary));
    
    D = max(max(img_edm)) - img_edm;  % EDM to be used for watershed
    
    
    % Adjust image to avoid oversegmentation.
    % by removing local minima that are only 1 pixel significant.
    D2 = imhmin(D, 1, 4);
    
    % Compute watershed
    img_ws = watershed(D2);  % perform watershed transform
    img_ws(~img_binary) = 0;  % reset background pixels
    
    
    % Compute particle characteristics.
    Pp = struct();
    for ii=max(max(img_ws)):-1:1
        img_pp = (img_ws==ii) .* img_edm;
        [i0, idx1] = max(img_pp);
        [Pp.radii(ii), idx2] = max(i0);
        idx1 = idx1(idx2);
        
        Pp.dp(ii) = Pp.radii(ii) .* 2 .* pixsize;
        
        Pp.centers(ii,:) = [idx2, idx1];
    end
    Pp.dpm = mean(Pp.dp);  % mean
    Pp.dpg = exp(mean(log(Pp.dp)));  % geometric mean
    
    
    % Copy data to Aggs structure.
    Aggs(aa).Pp_edm_ws = Pp;
    Aggs(aa).dp_edm_ws = Pp.dpg;
    Aggs(aa).dp = Pp.dpg;
    
    
    %-- Check the circle finder by overlaying on the original image 
    %   Circles in blue if part of considered aggregates
    if and(f_plot==1, ~isempty(Pp.centers))
        imagesc(img_ws);
        colormap(ax, cm);
        axis image;
        set(gca,'XTick',[]); % remove x-ticks
        set(gca,'YTick',[]); % remove y-ticks
        
        subplot(1,2,1);
        hold on;
        viscircles(Pp.centers, Pp.radii', 'EdgeColor', [0.92,0.16,0.49], ...
            'LineWidth', 0.75, 'EnhanceVisibility', false);
        hold off;
        drawnow;
        pause(0.8);
    end
    
    
    tools.textbar([aa, length(imgs_binary)]);

end % end loop over aggregates

if f_plot==1; close(f0); end

tools.textheader();


end
