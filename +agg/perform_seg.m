
% PERFORM_SEG  Automatically detects and segments aggregates in an image
% Authors:     Timothy Sipkens, Yeshun (Samuel) Ma, 2019
% 
% Note:
%   Originally structure given by Ramin Dastanpour, Hugo Tjong,
%   Arka Soewono from the University of British Columbia, 
%   Vanouver, BC, Canada.
%=========================================================================%

function [imgs_binary,imgs_aggs,Aggs] = perform_seg(imgs,pixsize,fname,opts)

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
    fname = {Imgs_str.fname};
elseif ~iscell(imgs)
    imgs = {imgs};
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

%-- Partially parse name-value pairs --%
if ~exist('opts','var'); opts = []; end
if isfield(opts,'fname'); fname = opts; end
%-------------------------------------------------------------------------%


imgs_binary = cell(length(imgs),1); % pre-allocate
for ii=1:length(imgs)%:-1:1 % loop through provided images
    
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
    
    Aggs0 = agg.analyze_binary(...
        img_binary,imgs{ii},pixsize(ii));
    
    if exist('fname','var')
        for aa=1:length(Aggs0)
            Aggs0(aa).fname = fname{ii};
        end
    end
    
    if ~exist('Aggs','var')
        Aggs = Aggs0;
    else
        Aggs = [Aggs,Aggs0]; % append to Aggs structure
    end
    
end

close(gcf); % close image with overlaid da
imgs_aggs = {Aggs.img_cropped};
disp('Complete.');
disp(' ');

end
