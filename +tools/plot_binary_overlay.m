
% PLOT_BINARY_OVERLAY  Plot original image with binary mask overlayed
% Author:              Timothy Sipkens, 2019-07-24
%=========================================================================%

function [h,f] = plot_binary_overlay(img,img_binary,bool_type)

if ~exist('bool_type','var'); bool_type = []; end
if isempty(bool_type); bool_type = 2; end

gcf;
clf;

if bool_type==1 % original impose from PCM code
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline

    t0 = imimposemin(img,img_dilated);
    imshow(t0);
    
    
elseif bool_type==2 % overlay labels with transparency
    img_edge = edge(img_binary,'sobel');
    SE = strel('disk',1);
    img_dilated = imdilate(img_edge,SE);
        % use dilation to strengthen the aggregate's outline
    
    t0 = labeloverlay(img,~img_binary,'Transparency',0.90);
    imshow(uint8(~img_dilated).*t0);

    
else % updates module for manual sizing
    SE = strel('disk',2);
    img_dilated = imdilate(img_binary,SE);
    img_edge = ~(img_binary-img_dilated);

    w1 = 1; % brightness of aggregate
    w2 = 0.3;
    t0 = img.*uint8(~img_binary);
    t1 = w2.*img.*uint8(img_edge)+(1-w2).*img;

    imshow(w1.*t1 + (1-w1).*t0);
end

if nargout>0; h = gca; end
if nargout>1; f = gcf; end

end

