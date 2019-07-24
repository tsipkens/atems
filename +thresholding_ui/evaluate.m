
% EVALUATE  Automatically detects and segments aggregates in an image
% Parameters:
%   img     Struct describing image, including fields containing fname, 
%           rawimage, cropped image, footer, ocr, and pixel size
%=========================================================================%

function Aggs = evaluate(Imgs)

ll = 0; % initialize aggregate counter

for ii=1:length(Imgs) % loop through provided images
    
    %-- Initialize parameters --------------------------------------------%
    pixsize = Imgs(ii).pixsize; % local copy of pixel size
    minparticlesize = 4.9; % to filter out noises
    
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
        % coefficients for automatic Hough transformation
    more_aggs = 0;


    % Build the image processing coefficients for the image based on its
    % magnification ------------------------------------------------------%
    if pixsize <= 0.181
        coeffs = coeff_matrix(1,:);
    elseif pixsize <= 0.361
        coeffs = coeff_matrix(2,:);
    else 
        coeffs = coeff_matrix(3,:);
    end

    %-- Run slider to obtain binary image --------------------------------%
    [total_binary,~,~,~] = ... 
        thresholding_ui.Agg_detection(Imgs(ii),pixsize, ...
        more_aggs,minparticlesize,coeffs);
    
    CC = bwconncomp(abs(total_binary-1)); % find seperate aggregates
    naggs = CC.NumObjects; % count number of aggregates
    Aggs(ll+naggs).fname = []; % pre-allocate new space for aggregates
    
    
    %== Main loop to analyze each aggregate ==============================%
    for jj = 1:naggs % loop through number of found aggregates
        
        % TODO: Remove any aggregates touching the edge
        
        ll = ll + 1; % increment aggregate counter
        
        Aggs(ll).fname = Imgs(ii).fname; % file name for aggregate
        Aggs(ll).pixsize = pixsize;
        Aggs(ll).image = Imgs(ii).Cropped;
            % store image that the aggregate occurs in
        
        %-- Step 3-2: Prepare an image of the isolated aggregate ---------%
        img_binary = zeros(size(total_binary));
        img_binary(CC.PixelIdxList{1,jj}) = 1;
        Aggs(ll).binary = img_binary;
        
        
        %== Compute aggregate dimensions/parameters ======================%
        SE = strel('disk',1);
        img_dilated = imdilate(img_binary,SE);
        img_edge = img_dilated-img_binary;
        
        [Aggs(ll).length, Aggs(ll).width] = ...
            thresholding_ui.Agg_Dimension(img_edge,pixsize);
            % calculate aggregate length and width
        Aggs(ll).aspect_ratio = Aggs(ll).length/Aggs(ll).width;
        
        Aggs(ll).num_pixels = nnz(img_binary); % number of non-zero pixels
        Aggs(ll).da = ((Aggs(ll).num_pixels/pi)^.5)*2*pixsize; % area-equialent diameter
        Aggs(ll).area = nnz(img_binary).*pixsize^2; % aggregate area
        Aggs(ll).Rg = ...
            thresholding_ui.gyration(img_binary,pixsize);
            % calculate radius of gyration
        
        Aggs(ll).perimeter = sum(sum(img_edge~=0))*pixsize;
            % calculate aggregate perimeter
        % Aggs(ll).perimeter = ...
        %     thresholding_ui.perimeter_length(img_binary,...
        %     pixsize,Aggs(ll).num_pixels); % alternate perimeter
            
        
    end
    
    close all; % close all images
        
end

end