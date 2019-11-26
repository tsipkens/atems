
% PERFORM_SEG  Automatically detects and segments aggregates in an image
% Authors:     Timothy Sipkens, Yeshun (Samuel) Ma, 2019
% 
% Note:
%   Originally structure given by Ramin Dastanpour, Hugo Tjong,
%   Arka Soewono from the University of British Columbia, 
%   Vanouver, BC, Canada.
%=========================================================================%

function [imgs_binary] = perform_seg(imgs,pixsize,opts)

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

%-- Partially parse name-value pairs --%
if ~exist('opts','var'); opts = []; end
%-------------------------------------------------------------------------%


imgs_binary = cell(length(imgs),1); % pre-allocate
for ii=1:length(imgs) % loop through provided images
    
    disp(['<== IMAGE ',num2str(ii),' =================================>']);
    
    %-- Initialize parameters --------------------------------------------%
    %   use defaults defined in seg instead
    
    %-- Run slider to obtain binary image --------------------------------%
    [img_binary,~,~,~] = agg.seg(...
        imgs{ii},pixsize(ii),[],[],...
        opts); % includes removing aggregates from border
    imgs_binary{ii} = img_binary;
    
    disp('Completed thresholding.');
    disp(' ');
    
end

close(gcf); % close image with overlaid da
disp('Complete.');
disp(' ');

end
