
% AGG_DET	Detection of the aggregates on TEM images
% Author:   Ramin Dastanpour, Steven N. Rogak
% Modified: Timothy Sipkens
% Developed at the University of British Columbia
%=========================================================================%

function [img_binary,img_cropped,agg_binary_bin,agg_cropped_bin] = ...
    agg_det(img,pixsize,minparticlesize,coeffs,opts) 

agg_binary_bin = {};    % Bin of binary aggregate images
agg_cropped_bin = {};   % Bin of cropped aggregated images


%== Parse inputs =========================================================%
if ~exist('pixsize','var'); pixsize = []; end
if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeff','var'); coeff = []; end

if isempty(pixsize); pixsize = 0.1; end % only used for coeffs (?)
if isempty(minparticlesize); minparticlesize = 4.9; end % to filter out noises
if isempty(coeff)
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
            % coefficient for automatic Hough transformation
    
    % Build the image processing coefficients for the image based on its
    % magnification
    if pixsize <= 0.181
        coeffs = coeff_matrix(1,:);
    elseif pixsize <= 0.361
        coeffs = coeff_matrix(2,:);
    else 
        coeffs = coeff_matrix(3,:);
    end
end

bool_kmeans = 1;
if ~exist('opts','var'); opts = []; end
if isfield(opts,'bool_kmeans'); bool_kmeans = opts.bool_kmeans; end
%-------------------------------------------------------------------------%


%== Attempt 1: k-means segmentation ======================================%
if bool_kmeans
    img_binary = agg_segment.agg_det_kmeans(...
        img,pixsize,minparticlesize,coeffs);
    [moreaggs,choice] = ...
        agg_segment.user_input(img,img_binary); % prompt user
    img_binary = ~imclearborder(~img_binary); % clear aggregates on border
else
    choice = 'No';
end



%== Attempt 2: Ostu + rolling ball transformation ========================%
if or(strcmp(choice,'No'),~bool_kmeans)
    img_binary = agg_segment.agg_det_hough(...
        img,pixsize,minparticlesize,coeffs);
    [moreaggs,choice] = agg_segment.user_input(...
        img,img_binary); % prompt user
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
        clear TempBW NewBW_lasoo NewBW
        [img_temp,rect] = agg_segment.agg_det_slider(img_cropped,0);
            % image is stored in a temporary image
        
        TempBW = img_temp;
            % the black part of the small cropped image is placed on the image
        
        TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1)) = ...
            NewBW_lasoo(1:round(rect(4))-1,1:round(rect(3))-1).*...
            TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1));
        imshow(TempBW);
        NewBW = TempBW;
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

