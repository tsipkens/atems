
% IMSHOW_AGG  Plot original image with binary mask overlayed
% Author: Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h, fr, i0] = imshow_agg(Aggs, idx, f_img, opts)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('idx','var'); idx = []; end % image index for plotting
if isempty(idx); idx = unique([Aggs.img_id]); end % plot all of the images
Nimg = length(idx); % number of images to plot

if ~exist('f_img','var'); f_img = []; end
if isempty(f_img); f_img = 1; end

if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts,'cmap'); opts.cmap = [0.12,0.59,0.96]; end
% determine which images will be plotted
%-------------------------------------------------------------------------%


%-- Prepare figure for plotting ------------------------------------------%
f0 = figure(gcf); % get handle for current figure

% Clear current figure if: plotting more than one image 
% OR plotting original image.
if or(f_img==1, Nimg>1); clf; end

% If more than one image, prepare to tile and maximize figure.
if Nimg>1
    f0.WindowState = 'maximized'; % maximize the figure window
    
    N1 = floor(sqrt(Nimg));
    N2 = ceil(Nimg/N1);
    subplot(N1, N2, 1);
end
%-------------------------------------------------------------------------%


if nargout>1; fr{Nimg} = []; end % inialize frame for output
for ii=1:Nimg % loop through images
    
    if Nimg>1 % if more than one image, prepare to tile
        subplot(N1, N2, ii);
    end
    
    %-- Determine which aggregates to plot for this image ----------------%
    idx0 = [Aggs.img_id]==idx(ii);
    idx_agg = 1:length(Aggs);
    idx_agg = idx_agg(idx0);


    %-- Plot labelled image by default -----------------------------------%
    if f_img
        % find all of the aggregates in the image of interest
        ind1 = find(idx0);
        img_binary = zeros(size(Aggs(idx_agg(1)).image));
        for aa=idx_agg
            img_binary = or(img_binary,Aggs(aa).binary);
        end

        [~,~,i0] = tools.imshow_binary( ...
            Aggs(ind1(1)).image, img_binary, opts);
    end % else: plot circles on existing image


    %-- Plot circles and identify aggregates -----------------------------%
    for aa=idx_agg
        hold on;

        % Plot center of mass of projected aggregate
        plot(Aggs(aa).center_mass(2), ...
            Aggs(aa).center_mass(1),...
            'xk', 'LineWidth', 0.75);
        text(Aggs(aa).center_mass(2) + 20, Aggs(aa).center_mass(1), ...
            num2str(Aggs(aa).id), 'Color', [0,0,0]);
            % label this point with aggregate no.
            % currently uses the global index in the Aggs structure

        % Plot radius of gyration on plot
        viscircles(fliplr(Aggs(aa).center_mass'),...
            Aggs(aa).Rg ./ Aggs(aa).pixsize, ... % / pixsize converts to pixel units
            'EnhanceVisibility', false, 'Color', opts.cmap);

        % Plot primary particle diameter from PCM if available
        if isfield(Aggs,'dp') % if available plot reference dp
            viscircles(fliplr(Aggs(aa).center_mass'), ...
                Aggs(aa).dp / 2 ./ Aggs(aa).pixsize, ... % use default value of dp
                'Color', [0.92,0.16,0.49], 'LineWidth', ...
                0.75, 'EnhanceVisibility', false);
        end
        hold off;
    end
    
    if nargout>1; f1 = getframe; fr{ii} = f1.cdata; end % get formatted image
end


if nargout>0; h = gca; end % output axis handle
if ~exist('i0','var'); i0 = []; end

end



