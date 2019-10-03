% Automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (thresholding_ui) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
%=========================================================================%

function [img_binary,img_cropped,agg_binary_bin,agg_cropped_bin] = ...
    Agg_detection(img,pixsize,moreaggs,minparticlesize,coeffs) 

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


%== Attempt 1: Hough transformation ======================================%
[img_binary,moreaggs,choice] = ...
    thresholding_ui.agg_det_hough(img,pixsize,moreaggs,minparticlesize,coeffs);

%-- Showing detected particles -------------------------------------------%
%   Make masked image so that user can see if particles have been 
%   erased or not
if size(img_binary,1)~=0
    img_edge = edge(img_binary,'sobel');
    se = strel('disk',1);
    img_dilated = imdilate(img_edge,se);
    
    img_final_imposed = imimposemin(img,img_dilated);
    h = figure;
    imshow(img_final_imposed);
end

%-- User interaction -----------------------------------------------------%
if strcmp(choice,'Yes') || strcmp(choice,'Yes, but reduce noise')
    clear choice;
    choice = questdlg('Are there any particles not detected?',...
        'Missing particles',...
        'Yes','No','No');
    if strcmp(choice,'Yes')
        moreaggs = 1;
    end
else
    moreaggs = 1;
    img_binary = [];
end

if size(img_binary,1)~=0; close(h); end
img_cropped = [];


%== Attempt 2: Manual thresholding ===================================%
while moreaggs==1
    [img_temp,rect,~,img_cropped] = thresholding_ui.Agg_det_Slider(img,1);
        % used previously cropped image
        % img_temp temporarily stores binary image
    
    img_edge = edge(img_temp,'sobel');
    se = strel('disk',1);
    img_dilated = imdilate(img_edge,se);
    
    img_final_imposed = imimposemin(img_cropped,img_dilated);
    h = figure;
    imshow(img_final_imposed);
    choice2 = questdlg('Satisfied with aggregate detection? If not, try drawing an edge around the aggregate manually...',...
        'Agg detection','Yes','No','Yes');
    close(h);
    
    
    %== Attempt 3: Manual thresholding, again ========================%
    if strcmp(choice2,'No')
        clear TempBW NewBW_lasoo NewBW
        [img_temp,rect] = thresholding_ui.Agg_det_Slider(img_cropped,0);
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
    
    img_edge = edge(img_binary,'sobel');
    se = strel('disk',1);
    img_dilated = imdilate(img_edge,se);
    
    img_final_imposed = imimposemin(img,img_dilated);
    h = figure;
    imshow(img_final_imposed);
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

