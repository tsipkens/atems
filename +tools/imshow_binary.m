
% INSHOW_BINARY  Plot original image with binary mask overlayed
% Author: Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h, i1] = imshow_binary(img, img_binary, opts)

%-- Parse inputs ---------------------------------------------------------%
if iscell(img); img = img{1}; end  % select only first image
if iscell(img_binary); img_binary = img_binary{1}; end

if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts,'cmap')
    opts.cmap = ones(max(max(img_binary)),1) * [0,1,1];
        % blue, repeated for as many labels as exist in img_binary
end
if ~isfield(opts,'f_outline'); opts.f_outline = 1; end
if ~isfield(opts,'label_alpha'); opts.label_alpha = 0.7; end
%-------------------------------------------------------------------------%


t0 = labeloverlay(img, img_binary, ...
    'Transparency', opts.label_alpha,...
    'Colormap', opts.cmap);

if ~opts.f_outline
    i1 = t0;
    
else % if adding an outline
    img_edge = edge(img_binary,'sobel');
    
    % Use dilation to strengthen the aggregate's outline.
    se = strel('disk', 1);
    img_dilated = or(img_binary - imdilate(img_binary, se), img_edge);
    
    % Adds borders to labeled regions.
    i1 = uint8(~img_dilated) .* t0;
end

tools.imshow(i1); % show labelled image

if nargout>0; h = gca; end % organize output

end

