% DETECT_AGGREGATE  Automatically detects and segments aggregates in an image
% Parameters:
%   img     Struct describing image, including fields containing fname, 
%           rawimage, cropped image, footer, ocr, and pixel size
%=========================================================================%

function Aggs = detect_aggregate(Imgs)

ll = 0; % initialize aggregate counter

for ii=1:length(Imgs) % loop through provided images
    
    %-- Initialize parameters --------------------------------------------%
    pixsize = Imgs(ii).pixsize; % local copy of pixel size
    minparticlesize = 4.9; % to filter out noises
    % Coefficient for automatic Hough transformation
    coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
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
    
    % total_binary = total_binary;
    
    CC = bwconncomp(abs(total_binary-1)); % find seperate aggregates
    naggs = CC.NumObjects; % count number of aggregates
    Aggs(ll+naggs).fname = []; % pre-allocate new space for aggregates
    
    for jj = 1:naggs % loop through number of found aggregates
        
        % TODO: Remove any aggregates touching the edge
        
        ll = ll + 1; % increment aggregate counter
        
        Aggs(ll).fname = Imgs(ii).fname; % file name for aggregate
        Aggs(ll).image = Imgs(ii).Cropped;
            % store image that the aggregate occurs in
        
        %-- Step 3-2: Prepare an image of the isolated aggregate ---------%
        Aggs(ll).binary = zeros(size(total_binary));
        Aggs(ll).binary(CC.PixelIdxList{1,jj}) = 1;
        Aggs(ll).pixsize = pixsize;
        
        
        %-- Calculating aggregate length and width -------------------%
        %   To determine the length and width of the agglomerate
        SE = strel('disk',1);
        img_dilated = imdilate(Aggs(ll).binary,SE);
        img_edge = img_dilated-Aggs(ll).binary;
        
        [Aggs(ll).length, Aggs(ll).width] = ...
            thresholding_ui.Agg_Dimension(img_edge,pixsize);
            % calculate aggregate length and width

        Aggs(ll).Rg = manual.Gyration(Aggs(ll).binary,pixsize);
            % calculate radius of gyration
        
    end
    
        
end

end