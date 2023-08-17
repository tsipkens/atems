
% IMSHOW_AGG  Plot original image with binary mask overlayed
% Author: Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h, fr, i0] = imshow_agg(Aggs, idx, f_img, opts)

%-- Parse inputs ---------------------------------------------------------%
% Determine which images will be plotted
if ~exist('idx','var'); idx = []; end % image index for plotting
if isempty(idx); idx = unique([Aggs.img_id]); end % plot all of the images

% Exceptions if idx indicates many images
if and(length(idx)>24, nargout<2) % plot a max. of 24 images (exception below)
    idx = idx(1:24);
end
n_img = length(idx); % number of images to plot

% Whether of not to plot image
if ~exist('f_img','var'); f_img = []; end
if isempty(f_img); f_img = 1; end

% Determine options for overlay
if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts,'cmap'); opts.cmap = [0.12,0.59,0.96]; end  % color to use, default is a blue
if ~isfield(opts,'f_text'); opts.f_text = 1; end  % whether or not to label aggregates with numbers
if ~isfield(opts,'f_show'); opts.f_show = 0; end  % whether to show images if just saving
if ~isfield(opts,'f_dp'); opts.f_dp = 1; end  % whether to show images if just saving
%-------------------------------------------------------------------------%


%-- Prepare figure for plotting ------------------------------------------%
% Clear current figure if: plotting more than one image 
% OR plotting original image.
if nargout>1
    fr{n_img} = [];  % inialize frame for output
    
    % New figure for saving plots, probably not shown to user.
    if opts.f_show==1; f0 = figure;
    else; f0 = figure('visible', 'off'); end
else
    f0 = gcf; % otherwise get current figure
    if or(f_img==1, n_img>1); clf; end
end

% If more than one image and not writing to file, tile figure.
if and(n_img>1, nargout<2)
    N1 = floor(sqrt(n_img));
    N2 = ceil(n_img/N1);
    subplot(N1, N2, 1);
end
%-------------------------------------------------------------------------%


if n_img>1; tools.textheader('Plotting aggregates');
    disp(' Resolving images:'); tools.textbar([0, n_img]); end
for ii=1:n_img % loop through images
    
    if and(n_img>1, nargout<2) % if more than one image, prepare to tile
        h = subplot(N1, N2, ii);
    end
    
    %-- Determine which aggregates to plot for this image ----------------%
    idx0 = [Aggs.img_id]==idx(ii);
    idx_agg = 1:length(Aggs);
    idx_agg = idx_agg(idx0);


    %-- Plot labelled image by default -----------------------------------%
    if f_img
        % find all of the aggregates in the image of interest
        idx1 = find(idx0);
        
        if isempty(idx1)
            warning(['No aggregates for image no. ', num2str(idx(ii)), '.']);
            continue;
        end
        
        img_binary = zeros(size(Aggs(idx_agg(1)).image));
        for aa=idx_agg
            img_binary = or(img_binary,Aggs(aa).binary);
        end

        [~,~,i0] = tools.imshow_binary2( ...
            Aggs(idx1(1)).image, img_binary, opts);
        
        % Make panels bigger.
        if and(n_img>1, nargout<2)
            title(num2str(idx(ii)));
            sc_h = 1.175;
            h.Position(3:4) = h.Position(3:4) .* sc_h;  % make panels 10% bigger
            h.Position(1:2) = h.Position(1:2) - ...
                h.Position(3:4) .* ((sc_h-1)/2);
        end
    end % else: plot circles on existing image


    %-- Plot circles and identify aggregates -----------------------------%
    for aa=idx_agg
        hold on;

        % Plot center of mass of projected aggregate
        plot(Aggs(aa).center_mass(2), ...
            Aggs(aa).center_mass(1),...
            'xk', 'LineWidth', 0.75);
        
        % Label this point with aggregate no., 
        % currently uses the global index in the Aggs structure.
        if opts.f_text
            text(Aggs(aa).center_mass(2) + 20, Aggs(aa).center_mass(1), ...
                num2str(Aggs(aa).id), 'Color', [0,0,0]);
        end

        % Plot radius of gyration on plot
        viscircles(fliplr(Aggs(aa).center_mass'),...
            Aggs(aa).Rg ./ Aggs(aa).pixsize, ... % / pixsize converts to pixel units
            'EnhanceVisibility', false, 'Color', opts.cmap);

        % Plot primary particle diameter from PCM if available
        if opts.f_dp
            if isfield(Aggs,'dp') % if available plot reference dp
                viscircles(fliplr(Aggs(aa).center_mass'), ...
                    Aggs(aa).dp / 2 ./ Aggs(aa).pixsize, ... % use default value of dp
                    'Color', [0.92,0.16,0.49], 'LineWidth', ...
                    0.75, 'EnhanceVisibility', false);
            end
        end
        hold off;
    end
    
    if nargout>1  % get formatted image if output required
        axis off;
        f1 = getframe;
        fr{ii} = f1.cdata;
    end
    
    if n_img>1; tools.textbar([ii, n_img]); end
end
 

%-- Parse outputs --------------------------------------------------------%
if and(nargout>1, n_img==1); fr = fr{1}; end  % output image instead of cell if only one image

if nargout==0; clear h;  % clear h if not required
elseif nargout==1; h = gca;  % output axis handle
elseif nargout>1; h =[]; end  % axis handle not output if figure deleted

if nargout>1; close(f0);  % if only saving images, delete figure
elseif n_img>1; f0.WindowState = 'maximized';  % otherwise, maximize the figure window

if ~exist('i0','var'); i0 = []; end
%-------------------------------------------------------------------------%

drawnow;  % draw the plot
if n_img>1; tools.textheader(); end

end



