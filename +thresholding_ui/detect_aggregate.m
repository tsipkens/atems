% AUTOMATIC/SEMI-AUTOMATIC AGGREGATE DETECTION
% Parameters:
%   img     Struct describing image, including fields containing fname, 
%           rawimage, cropped image, footer, ocr, and pixel size
% Return Types:
%	binary      Binary image from running threshold slider
%	dilated 	Dilated image from running imdilate on Sobel edge detection
%   imposed 	Imposed image of cropped and dilated edge
%=========================================================================%

function imgs = detect_aggregate(imgs)

for ii=1:length(imgs)
    
    %-- Initialize Parameters --------------------------------------------%
    pixsize = imgs(ii).pixsize;
    minparticlesize = 4.9; % to filter out noises
    % Coefficient for automatic Hough transformation
    coeff_matrix    = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
        0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
    moreaggs    = 0;


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
    imgs(ii).Binary = thresholding_ui.Agg_detection(imgs(ii),pixsize, ...
        moreaggs,minparticlesize,coeffs);

    imgs(ii).Edge = edge(imgs(ii).Binary,'sobel'); % Sobel edge detection
    SE = strel('disk',1);
    imgs(ii).DilatedEdge = imdilate(imgs(ii).Edge,SE); % morphological dilation

    %-- Generate impoced image -------------------------------------------%
    imgs(ii).Imposed = imimposemin(imgs(ii).Cropped, imgs(ii).DilatedEdge);
        
end

end