
% AGGCROP  Crops a single aggregate from an image.
%  
%  AUTHOR: Timothy Sipkens, 2024-02-16

function [imgs_binary, imgs, rect] = ...
    aggcrop(Aggs, idx, boundary, f_plot)

if ~exist('f_plot', 'var'); f_plot = []; end
if isempty(f_plot); f_plot = 0; end

if ~exist('boundary', 'var'); boundary = []; end
if isempty(boundary); boundary = 20; end  % percent boundary


% Parse inputs.
imgs_binary = {Aggs(idx).binary};
pixsizes = [Aggs(idx).pixsize];

imgs = {Aggs(~cellfun(@isempty, {Aggs.image})).image};
imgs = imgs([Aggs(idx).img_id]);


% Loop through images and crop.
for ii=1:length(imgs_binary)
    img_binary = imgs_binary{ii};

    [x,y] = find(img_binary);
    
    n = size(img_binary);  % size of image
    
    % Find coordinates of top and bottom of aggregate
    boundary_ii = max(ceil([max(x) - min(x), ...
        max(y) - min(y)] .* (boundary/100)), 5);  % add boundary as percent or 3 pixels
    x_top = min(max(x) + boundary_ii(1), n(1)); 
    x_bottom = max(min(x) - boundary_ii(1), 1);
    y_top = min(max(y) + boundary_ii(2), n(2)); 
    y_bottom = max(min(y) - boundary_ii(2), 1);

    imgs_binary{ii} = full(img_binary(x_bottom:x_top, y_bottom:y_top));
    imgs{ii} = imgs{ii}(x_bottom:x_top, y_bottom:y_top);
    rect = [y_bottom, x_bottom, (y_top-y_bottom), (x_top-x_bottom)];
end

if f_plot == 1
    tools.imshow_binary2(imgs, imgs_binary, pixsizes);
elseif f_plot == 2
    tools.imshow2(imgs, [], [], pixsizes);
end

end
