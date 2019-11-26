
% PLOT_AGGREGATES  Plot original image with binary mask overlayed
% Author:          Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = plot_aggregates(Aggs,ind,bool_img,opts)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('ind','var'); ind = []; end
if isempty(ind); ind = 1; end

if ~exist('bool_img','var'); bool_img = []; end
if isempty(bool_img); bool_img = 1; end

if ~exist('opts','var'); opts = struct(); end

% find the aggregates in that file
ind0 = strcmp({Aggs.fname},{Aggs(ind).fname});
ind_agg = 1:length(Aggs);
ind_agg = ind_agg(ind0);
%-------------------------------------------------------------------------%


%-- Plot labelled image by default ---------------------------------------%
if bool_img
    img_binary = zeros(size(Aggs(ind0(1)).image));
    for aa=ind_agg
        img_binary = or(img_binary,Aggs(aa).binary);
    end
    
    figure(gcf);
    [~,~,i0] = tools.plot_binary_overlay(Aggs(ind0(1)).image,...
        img_binary,opts);
end % else: plot circles on existing image


%-- Plot circles and identify aggregates ---------------------------------%
for aa=ind_agg
    hold on;
    plot(Aggs(aa).center_mass(2),Aggs(aa).center_mass(1),...
        'yx','LineWidth',1);
    viscircles(fliplr(Aggs(aa).center_mass'),...
        Aggs(aa).Rg./Aggs(aa).pixsize);
    text(Aggs(aa).center_mass(2)+20,Aggs(aa).center_mass(1),...
        num2str(Aggs(aa).id),'Color','white');
    
    if isfield(Aggs,'dp_pcm_simple') % if available plot reference dp
        viscircles(fliplr(Aggs(aa).center_mass'),...
            Aggs(aa).dp_pcm_simple/2./Aggs(aa).pixsize,...
            'Color','y','LineWidth',1);
    end
    hold off;
end


if nargout>0; h = gca; end
if nargout>1; f = gcf; end
if ~exist('i0','var'); i0 = []; end

end



