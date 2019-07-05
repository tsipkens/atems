%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function Thresh_Slider(hObj,event,ax) %#ok<INUSL>

Fontsize = 10;
global Thresh_slider_in Im_Dir mainfolder

load Imdirectory.mat Im_Dir mainfolder
cd(mainfolder)
cd('../data/ManualOutput')
load Imdata.mat binaryImage % binaryImage
cd(mainfolder)

%% "average" filter
hav = fspecial('average');
Filtered_Image_1 = imfilter(Thresh_slider_in, hav);
clear hav

%% median filter2
% using the median filter2 function, examine a neighborhood WxW matrix,
% take and make the centre of that matrix the median of the original
% neighborhood.  Specialized for "salt and pepper" noise.

W = 5;
Thresh_slider_in = medfilt2(Filtered_Image_1 , [W W]);

    %% Binary image via threshold value
    val = get(hObj,'Value');
    adj=val
    level = graythresh(Thresh_slider_in);
    
    level = level+adj; 

    Binary_Image_1 = im2bw(Thresh_slider_in,level);
    
    %% Binary image via Dilation  
    % to reduce initial noise and fill initial gaps
    SE1 = strel('square',1);
    Binary_Image_2 = imdilate(~Binary_Image_1,SE1);
    
    %% Refining binary image. Before refinig, thresholding causes some
    % errors, initiating from edges, which grow toward the aggregate. In
    % this section, external boundary, or background region, is utilized to
    % eliminate detection errors in the background region.
    Binary_Image_3=0.*Binary_Image_2;
    Binary_Image_3(binaryImage)=Binary_Image_2(binaryImage);
    Binary_Image_4=logical(Binary_Image_3);
    
    %% Binary image with growing errors
    %   temp_image=imimposemin(refined_Surf_imu8,Binary_Image_2);
    %   imshow(temp_image);
    
    %%
    temp_image2=imimposemin(Thresh_slider_in,Binary_Image_4);
    imshow(temp_image2);
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    
    %% Saving results
    cd(mainfolder)
    cd('../data/ManualOutput')
    save Thresh1.mat Filtered_Image_1 Binary_Image_1 Binary_Image_2 ...
        Binary_Image_3 Binary_Image_4 % binaryImage
    cd(mainfolder)
    
 end
