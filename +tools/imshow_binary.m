
% INSHOW_BINARY  Plot original image with binary mask overlayed
% Author: Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = imshow_binary(imgs, imgs_binary, opts)

%-- Parse inputs ---------------------------------------------------------%
% Convert images to cells, if they are not already.
if ~iscell(imgs); imgs = {imgs}; end
if ~iscell(imgs_binary); imgs_binary = {imgs_binary}; end

if length(imgs)>24 % only plot up to 24 images
    imgs = imgs(1:24);
    imgs_binary = imgs_binary(1:24);
end
n_imgs = length(imgs); % number of images

if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts,'cmap')
    opts.cmap = ones(max(max(imgs_binary{1})),1) * [0.12,0.59,0.96];
        % blue, repeated for as many labels as exist in img_binary
end
if ~isfield(opts,'f_outline'); opts.f_outline = 1; end
if ~isfield(opts,'label_alpha'); opts.label_alpha = 0.7; end
%-------------------------------------------------------------------------%



% If more than one image, prepare to tile and maximize figure.
if n_imgs>1
    N1 = floor(sqrt(n_imgs));
    N2 = ceil(n_imgs/N1);
    subplot(N1, N2, 1);
end


for ii=1:n_imgs % loop over images
    
    if n_imgs>1
        subplot(N1, N2, ii);
        title(num2str(ii));
    end
    
    t0 = labeloverlay(imgs{ii}, imgs_binary{ii}, ...
        'Transparency', opts.label_alpha,...
        'Colormap', opts.cmap);
    
    if ~opts.f_outline
        i1 = t0;
    else % if adding an outline
        img_edge = edge(imgs_binary{ii},'sobel');
        se = strel('disk',1);
        img_dilated = imdilate(img_edge,se);
            % use dilation to strengthen the aggregate's outline
        i1 = uint8(~img_dilated).*t0;
            % adds borders to labeled regions
    end
    
    tools.imshow(i1); % show labelled image
    
    if ii==1; i0 = i1; end % store first figure panel for output
    
end


if nargout>0; h = gca; end % organize outputs
if nargout>1; f = gcf; end

end

