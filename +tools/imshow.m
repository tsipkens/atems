
% IMSHOW  A modified version of iamgesc that formats images for this program.
% Timothy Sipkens, 2020-08-25
%=========================================================================%

function h = imshow(img, cmap, pixsize)

if ~exist('cmap', 'var'); cmap = []; end
if isempty(cmap); cmap = gray; end

if ~exist('pixsize', 'var'); pixsize = []; end

h = imagesc(img); % show image
colormap(cmap); % apply colormap (grayscale, by default)
axis image; % adjust the axis to proper dimensions
set(gca,'XTick',[]); % remove x-ticks
set(gca,'YTick',[]); % remove y-ticks

if ~isempty(pixsize)
    tools.overlay_scale(pixsize);
end

if nargout==0; clear h; end

end

