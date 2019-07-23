% AUTOMATIC/SEMI-AUTOMATIC AggsREGATE DETECTION
% Parameters:
%   img     Struct describing image, including fields containing fname, 
%           rawimage, cropped image, footer, ocr, and pixel size
% Return Types:
%	img     Struct with additional fields
            
%=========================================================================%

function Aggs = detect_aggregate(imgs)

ll = 0;

for ii=1:length(imgs)
    
    %-- Initialize Parameters --------------------------------------------%
    pixsize = imgs(ii).pixsize;
    minparticlesize = 4.9; % to filter out noises
    % Coefficient for automatic Hough transformation
    coeff_matrix    = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
    moreAggs    = 0;


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
        thresholding_ui.Agg_detection(imgs(ii),pixsize, ...
        moreAggs,minparticlesize,coeffs);
    
    % total_binary = total_binary;
    
    CC = bwconncomp(abs(total_binary-1));
    NofAggss = CC.NumObjects; % count number of particles
    
    for nAggs = 1:NofAggss
        
        % TODO: Remove any aggregates touching the edge
        
        ll = ll + 1; % increment Aggsregate counter
        
        Aggs(ll).fname = imgs(ii).fname;
        
        %-- Step 3-2: Prepare an image of the isolated Aggsregate ---------%
        Aggs(ll).binary = zeros(size(total_binary));
        Aggs(ll).binary(CC.PixelIdxList{1,nAggs}) = 1;
        Aggs(ll).image = imgs(ii).Cropped;
        Aggs(ll).pixsize = imgs(ii).pixsize;
    end
    
        
end

end