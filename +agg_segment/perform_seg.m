
% PERFORM_SEG  Automatically detects and segments aggregates in an image
% Authors:     Timothy Sipkens, Yeshun (Samuel) Ma, 2019

% Note:
%   Originally written by Ramin Dastanpour, Steve Rogak, Hugo Tjong,
%   Arka Soewono from the University of British Columbia, 
%   Vanouver, BC, Canada
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
    minparticlesize = 4.9; % to filter out noises
    
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
        % coefficients for automatic Hough transformation
    
    
    % Build the image processing coefficients for the image based on its
    % magnification ------------------------------------------------------%
    if pixsize(ii) <= 0.181
        coeffs = coeff_matrix(1,:);
    elseif pixsize(ii) <= 0.361
        coeffs = coeff_matrix(2,:);
    else 
        coeffs = coeff_matrix(3,:);
    end
    
    %-- Run slider to obtain binary image --------------------------------%
    [img_binary,~,~,~] = agg_segment.agg_det(...
        imgs{ii},pixsize(ii),minparticlesize,coeffs,...
        opts); % includes removing aggregates from border
    imgs_binary{ii} = img_binary;
    
    disp('Completed thresholding.');
    disp(' ');
    
    Aggs0 = agg_segment.analyze_agg(...
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
