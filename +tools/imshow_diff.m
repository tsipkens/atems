
% IMSHOW_DIFF  Plot original and labeled images side-by-side.
%  NOTE: IDX corresponds to the aggregate index, not the image index.
%  
%  Author: Timothy Sipkens, 2024-01-29

function [] = imshow_diff(Aggs, idx, varargin)

clf;  % as this requires a specific image arrangement

% First subplot labels the aggregates.
subplot(1, 2, 2);
tools.imshow_agg(Aggs, idx, varargin{:});

% Second plot shows original image. 
subplot(1, 2, 1);
img_id = Aggs(idx).img_id;
img_id = find([Aggs.img_id] == img_id, 1);
tools.imshow(Aggs(img_id).image, [], Aggs(img_id).pixsize);

end
