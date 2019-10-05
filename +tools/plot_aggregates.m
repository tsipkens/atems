
% PLOT_AGGREGATES  Plot original image with binary mask overlayed
% Author:          Timothy Sipkens, 2019-07-24
%=========================================================================%

function h = plot_aggregates(Imgs,Aggs,ind)

if ~exist('ind','var'); ind = []; end
if isempty(ind); ind = 1; end

figure(gcf);
tools.plot_binary_overlay(Imgs(ind).cropped,...
    Imgs(ind).binary);

for aa=1:length(Aggs)
    if strcmp(Aggs(aa).fname,Imgs(ind).fname)
        hold on;
        plot(Aggs(aa).center_mass(2),Aggs(aa).center_mass(1),'rx');
        viscircles(fliplr(Aggs(aa).center_mass'),...
            Aggs(aa).Rg./Aggs(aa).pixsize);
        text(Aggs(aa).center_mass(2)+12,Aggs(aa).center_mass(1),...
            num2str(Aggs(aa).id),'Color','blue');
        hold off;
    end
end

if nargout>0; h = gca; end

end



