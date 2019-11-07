
% PLOT_AGGREGATES  Plot original image with binary mask overlayed
% Author:          Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = plot_aggregates(Aggs,Imgs,ind,bool_img,cmap)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('ind','var'); ind = []; end
if isempty(ind); ind = 1; end

if ~exist('bool_img','var'); bool_img = []; end
if isempty(bool_img); bool_img = 1; end

if ~exist('cmap','var'); cmap = []; end

if ~isempty(Imgs) % if Imgs provided, find the aggregates in that file
    ind0 = strcmp({Aggs.fname},{Imgs(ind).fname});
    ind_agg = 1:length(Aggs);
    ind_agg = ind_agg(ind0);
else % otherwise, plot aggregate specified by 'ind'
    ind_agg = ind;
end
%-------------------------------------------------------------------------%


%-- Plot labelled image by default ---------------------------------------%
if bool_img
    figure(gcf);
    [~,~,i0] = tools.plot_binary_overlay(Imgs(ind).cropped,...
        Imgs(ind).binary,[],cmap);
end % else: plot circles on existing image


%-- Plot circles and identify aggregates ---------------------------------%
for aa=ind_agg
    hold on;
    plot(Aggs(aa).center_mass(2),Aggs(aa).center_mass(1),'rx');
    viscircles(fliplr(Aggs(aa).center_mass'),...
        Aggs(aa).Rg./Aggs(aa).pixsize);
    text(Aggs(aa).center_mass(2)+12,Aggs(aa).center_mass(1),...
        num2str(Aggs(aa).id),'Color','white');
    hold off;
end


if nargout>0; h = gca; end
if nargout>1; f = gcf; end
if ~exist('i0','var'); i0 = []; end

end



