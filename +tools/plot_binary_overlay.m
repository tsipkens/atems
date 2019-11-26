
% PLOT_BINARY_OVERLAY  Plot original image with binary mask overlayed
% Author:              Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = plot_binary_overlay(img,img_binary,opts)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('opts','var'); opts = struct(); end

if ~isfield(opts,'cmap')
    opts.cmap = ones(max(max(img_binary)),1)*[0,0,1];
        % blue, repeated for as many labels as exist in img_binary
end

if ~isfield(opts,'bool_outline'); opts.bool_outline = 1; end
if ~isfield(opts,'label_alpha'); opts.label_alpha = 0.7; end
%-------------------------------------------------------------------------%


gcf; % get and clear figure
clf;

t0 = labeloverlay(img,img_binary,...
    'Transparency',opts.label_alpha,...
    'Colormap',opts.cmap);


if ~opts.bool_outline
    i0 = t0;
else % if adding an outline
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline
    i0 = uint8(~img_dilated).*t0;
        % adds borders to labeled regions
end


imshow(i0); % show labelled image


if nargout>0; h = gca; end % organize outputs
if nargout>1; f = gcf; end

end

