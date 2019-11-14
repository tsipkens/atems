
% PLOT_BINARY_OVERLAY  Plot original image with binary mask overlayed
% Author:              Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f,i0] = plot_binary_overlay(img,img_binary,bool_type,cmap)

if ~exist('bool_type','var'); bool_type = []; end
if isempty(bool_type); bool_type = 2; end

if ~exist('cmap','var'); cmap = []; end
if isempty(cmap); cmap = [0,0,1]; end


gcf;
clf;

if bool_type==1 % original impose from PCM code
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline

    i0 = imimposemin(img,img_dilated);
    
elseif bool_type==2 % overlay labels with transparency
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline
    
    t0 = labeloverlay(img,img_binary,...
        'Transparency',0.90,...
        'Colormap',cmap);
    i0 = uint8(~img_dilated).*t0;
    
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

