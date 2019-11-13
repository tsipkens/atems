
% AGG_DET	Sequential attempts at semi-automatic detection of the aggregates on TEM images.
%           Attempts k-means + rolling ball, Otsu + rolling ball, slider
%           thresholding. Acts as a wrapper function for implementing 
%           several other agg_det*.m methods
% Author:   Ramin Dastanpour, Steven N. Rogak
%           Developed at the University of British Columbia
% Modified: Timothy Sipkens, 2019
%=========================================================================%

function [img_binary,img_cropped,agg_binary_bin,agg_cropped_bin] = ...
    agg_det(img,pixsize,minparticlesize,coeffs,opts) 

agg_binary_bin = {};    % Bin of binary aggregate images
agg_cropped_bin = {};   % Bin of cropped aggregated images


%== Parse inputs =========================================================%
if ~exist('pixsize','var'); pixsize = []; end
if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

bool_kmeans = 1;
bool_otsu = 1;
if ~exist('opts','var'); opts = []; end
if isfield(opts,'bool_kmeans'); bool_kmeans = opts.bool_kmeans; end
if isfield(opts,'bool_otsu'); bool_otsu = opts.bool_otsu; end
%-------------------------------------------------------------------------%


%== Attempt 1: k-means segmentation + rolling ball transformation ========%
if bool_kmeans
    img_binary = agg_segment.agg_det_kmeans_rb(...
        img,pixsize,minparticlesize,coeffs);
    [moreaggs,choice] = ...
        agg_segment.user_input(img,img_binary); % prompt user
    img_binary = ~imclearborder(~img_binary); % clear aggregates on border
else
    choice = 'No';
end



%== Attempt 2: Ostu + rolling ball transformation ========================%
if or(strcmp(choice,'No'),~bool_kmeans)
    if bool_otsu
        img_binary = agg_segment.agg_det_otsu_rb(...
            img,pixsize,minparticlesize,coeffs);
        [moreaggs,choice] = agg_segment.user_input(...
            img,img_binary); % prompt user
    else
        choice = 'No'; moreaggs = 1;
    end
    if strcmp(choice,'No'); img_binary = ones(size(img)); end
end

img_cropped = [];



%== Attempt 3: Manual thresholding =======================================%
while moreaggs==1
    [img_temp,rect,~,img_cropped] = agg_segment.agg_det_slider(img,1);
        % used previously cropped image
        % img_temp temporarily stores binary image
    
    [~,f] = tools.plot_binary_overlay(...
        img_cropped,img_temp);
    
    choice2 = questdlg('Satisfied with aggregate detection? If not, try drawing an edge around the aggregate manually...',...
        'Agg detection','Yes','No','Yes');
    
    close(f);
    
    
    %== Attempt 4: Manual thresholding, again ============================%
    if strcmp(choice2,'No')
        [img_temp,rect,~,img_cropped] = agg_segment.agg_det_slider(img,1);
            % image is stored in a temporary image
    end
    
    agg_binary_bin  = [agg_binary_bin, img_temp];
    agg_cropped_bin = [agg_cropped_bin, img_cropped];
    
    %-- Subsitute rectangle back into orignal image ----------------------%
    if isempty(img_binary)
        img_binary = ones(size(img));
    end
    rect = round(rect);
    size_temp = size(img_temp);
    
    inds1 = rect(2):(rect(2)+size_temp(1)-1);
    inds2 = rect(1):(rect(1)+size_temp(2)-1);
    img_binary(inds1,inds2) = ...
        img_binary(inds1,inds2).*img_temp;
    
    %-- Query user -------------------------------------------------------%
    h = figure(gcf);
    tools.plot_binary_overlay(img,img_binary);
    f = gcf;
    f.WindowState = 'maximized'; % maximize figure
    
    choice = questdlg('Are there any particles not detected?',...
        'Missing particles','Yes','No','No');
    if strcmp(choice,'Yes')
        moreaggs=1;
    else
        moreaggs=0;
    end
    
    close(h);
end

end

