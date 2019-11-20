
% PLOT_BINARY_OVERLAY  Plot original image with binary mask overlayed
% Author:              Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = plot_binary_overlay(img,img_binary,...
    cmap,bool_type,bool_outline,label_alpha)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('cmap','var'); cmap = []; end
if isempty(cmap); cmap = [0,0,1]; end

if ~exist('bool_type','var'); bool_type = []; end
if isempty(bool_type); bool_type = 2; end

if ~exist('bool_outline','var'); bool_outline = []; end
if isempty(bool_outline); bool_outline = 1; end

if ~exist('label_alpha','var'); label_alpha = []; end
if isempty(label_alpha); label_alpha = 0.7; end
%-------------------------------------------------------------------------%



gcf;
clf;

if bool_type==1 % original impose from PCM code
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline

    i0 = imimposemin(img,img_dilated);
    
elseif bool_type==2 % overlay labels with transparency
    t0 = labeloverlay(img,img_binary,...
        'Transparency',label_alpha,...
        'Colormap',cmap);
    
    if ~bool_outline
        i0 = t0;
    else
        img_edge = edge(img_binary,'sobel');
        SE = strel('disk',1);
        img_dilated = imdilate(img_edge,SE);
            % use dilation to strengthen the aggregate's outline
        i0 = uint8(~img_dilated).*t0;
            % adds borders to labeled regions
    end
    
else % updates module for manual sizing
    SE = strel('disk',2);
    img_dilated = imdilate(img_binary,SE);
    img_edge = ~(img_binary-img_dilated);

    w1 = 1; % brightness of aggregate
    w2 = 0.3;
    t0 = img.*uint8(~img_binary);
    t1 = w2.*img.*uint8(img_edge)+(1-w2).*img;
    i0 = w1.*t1 + (1-w1).*t0;
    
end

imshow(i0);

if nargout>0; h = gca; end
if nargout>1; f = gcf; end

end

