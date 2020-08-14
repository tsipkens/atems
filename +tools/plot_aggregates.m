
% PLOT_AGGREGATES  Plot original image with binary mask overlayed
% Author:          Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h, f, i0] = plot_aggregates( ...
    Aggs, ind, bool_img, opts)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('ind','var'); ind = []; end
if isempty(ind); ind = 1; end

if ~exist('bool_img','var'); bool_img = []; end
if isempty(bool_img); bool_img = 1; end

if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts,'cmap'); opts.cmap = [0.12,0.59,0.96]; end

% find the aggregates in that file
ind0 = strcmp({Aggs.fname},{Aggs(ind).fname});
ind_agg = 1:length(Aggs);
ind_agg = ind_agg(ind0);
%-------------------------------------------------------------------------%


%-- Plot labelled image by default ---------------------------------------%
if bool_img
    % find all of the aggregates in the image of interest
    ind1 = find(ind0);
    img_binary = zeros(size(Aggs(ind1(1)).image));
    for aa=ind_agg
        img_binary = or(img_binary,Aggs(aa).binary);
    end
    
    figure(gcf);
    [~,~,i0] = tools.plot_binary_overlay( ...
        Aggs(ind1(1)).image, img_binary, opts);
end % else: plot circles on existing image


%-- Plot circles and identify aggregates ---------------------------------%
for aa=ind_agg
    hold on;
    
    % plot center of mass of projected aggregate
    plot(Aggs(aa).center_mass(2), ...
        Aggs(aa).center_mass(1),...
        'xk', 'LineWidth', 0.75);
    text(Aggs(aa).center_mass(2) + 20, Aggs(aa).center_mass(1), ...
        num2str(aa), 'Color', [0,0,0]);
        % label this point with aggregate no.
        % currently uses the global index in the Aggs structure
    
    % plot radius of gyration on plot
    viscircles(fliplr(Aggs(aa).center_mass'),...
        Aggs(aa).Rg ./ Aggs(aa).pixsize, ... % / pixsize converts to pixel units
        'EnhanceVisibility', false, 'Color', opts.cmap);
    
    % plot primary particle diameter from PCM if available
    if isfield(Aggs,'dp_pcm_simple') % if available plot reference dp
        viscircles(fliplr(Aggs(aa).center_mass'),...
            Aggs(aa).dp_pcm_simple/2./Aggs(aa).pixsize,...
            'Color', [0.92,0.16,0.49], 'LineWidth', 0.75, 'EnhanceVisibility', false);
    end
    hold off;
end


if nargout>0; h = gca; end % output axis handle
if nargout>1; f = getframe; f = f.cdata; end % just image pane
if ~exist('i0','var'); i0 = []; end

end



