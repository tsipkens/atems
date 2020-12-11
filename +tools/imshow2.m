
% IMSHOW2  A wrapper for tools.imshow() that shows multiple images.
% Timothy Sipkens, 2020-12-10
%=========================================================================%

function h = imshow2(imgs, cmap)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('cmap','var'); cmap = []; end
if isempty(cmap); cmap = gray; end

if ~iscell(imgs); imgs = {imgs}; end
n_imgs = length(imgs);
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
    
    tools.imshow(imgs{ii}); % show labelled image
    
end


if nargout>0; h = gca; end % organize outputs
if nargout>1; f = gcf; end

end

