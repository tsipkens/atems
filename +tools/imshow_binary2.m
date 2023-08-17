
% INSHOW_BINARY  Plot original image with binary mask overlayed
% Author: Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = imshow_binary2(imgs, imgs_binary, varargin)

%-- Parse inputs ---------------------------------------------------------%
% Convert images to cells, if they are not already.
if ~iscell(imgs); imgs = {imgs}; end
if ~iscell(imgs_binary); imgs_binary = {imgs_binary}; end

if length(imgs)>24 % only plot up to 24 images
    imgs = imgs(1:24);
    imgs_binary = imgs_binary(1:24);
end
n_imgs = length(imgs); % number of images
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
    
    [~, i1] = tools.imshow_binary(imgs{ii}, imgs_binary{ii}, varargin{:});
    
    if ii==1
        if nargout>0; h = gca; end  % organize outputs
        i0 = i1;  % store first figure panel for output
    end
    
end

if nargout>1; f = gcf; end

end

