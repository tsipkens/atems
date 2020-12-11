
% ALTENHOFF  A wrapper function to apply the Hough transform via Peng's implementation.
%  This corresponds to the approach taken by Altenhoff et al. in their work.
%  Peng's original function is given as a submethod.
% Author: Timothy Sipkens, 2020-12-11
% Based on: Altenhoff et al. (2020)
%=========================================================================%

function [centers, radii] = altenhoff(Aggs, f_plot)

if ~exist('f_plot', 'var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end

tools.textheader('Performing Altenhoff (Hough)');

if f_plot==1; f0 = figure; end  % generate figure, if f_plot==1


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
    
    img = Aggs(a1).image;
    pixsize = Aggs(a1).pixsize;
    
    
    %== Find and draw circles within aggregates ==========================%
    %   Find circles within soot aggregates 
    [~, centers, radii] = pp.hough_peng( ...
        img, [5,60], 20, 20, 1);
    
    
    %-- Check the circle finder by overlaying boundaries on the original image
    if f_plot==1
        tools.imshow(Aggs(a1).image); drawnow;
        hold on;
        viscircles(centers, radii', 'EdgeColor', [0.1,0.1,0.1], ...
        	'LineWidth', 0.75, 'EnhanceVisibility', false);
        hold off;
        drawnow;
    end
    
    
    %-- Loop over aggregates for this image ------------------------------%
    for aa=idx_agg
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
end

dp = [Aggs.dp]; % compile dp output
if f_plot==1; close(f0); end

tools.textheader();

end



