%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [img_binary5, img_manual_edge, img_final_imposed] = Thresh_refine(img_binary,Thresh_slider_in)


%-- Binary image via SELECTION -------------------------------------------%
% to further reduce the noise, and solve the area calculation problems of
% multiple particle images

uiwait(msgbox('Please select which particle(s) wished to be analyzed.\nDouble click, or right click, or shift-click on the desired particle.\nNote that only one particle may be selected per analysis!',...
    'Process Stage: Manual Artifact Removal','help'));
img_binary5 = bwselect(img_binary,8);


%-- Imposed image --------------------------------------------------------%
% to get particle, with no background, thus eliminating the semi-large
% carbon frames in the background
% impose the inverse of Binary_Image_5 on Filtered_Image_2

% Imposed_Image = imimposemin(Thresh_slider_in, ~Binary_Image_5);
img_imposed = img_binary5; % currently skipping this step


%-- Edge detection via Sobel ---------------------------------------------%
% Use Sobel's Method as a built-in edge detection function for particle's 
% outline.  Can consider using other methods (Roberts, Canny, etc)

img_edge = edge(img_imposed,'sobel');


%-- Dilated Edge Image ---------------------------------------------------%
% to strengthen the particle's outline, use dilation

SE2 = strel('disk',1);
img_dilate = imdilate(img_edge,SE2);


%-- Manual edge detection on image ---------------------------------------%
% to get rid of large spots that are not part of the image obvious to the
% human eye.  May consider automating this process later on for cleaner
% images

pass=0;
while pass==0
    
    uiwait(msgbox('Please LEFT click on the pixels that are clearly not part of the outline.  Push ENTER when finish.',...
        'Process Stage: Manual Edge','help'));
    img_temp_edge = bwselect(img_dilate,4);
    close all
    img_manual_edge = img_dilate-img_temp_edge;
    
    imshow(img_manual_edge);
    
    choice = questdlg('Do you want to repeat the Manual Edge process?',...
        'Manual Edge Clarification','Yes',...
        'No','Yes'); 
    close all
    if  strcmp(choice,'No') == 1
        pass = 1;
    end

end

img_final_imposed = imimposemin(Thresh_slider_in, img_manual_edge);


% Saving Images
%{
% Currently commented to prevent changing of folder
cd('data')
if exist('ManualOutput','dir')~=7 %checking wheter the Output folder available 
    mkdir('ManualOutput')
end
cd('ManualOutput')

imwrite(Thresh_slider_in,[FileName '_Filtered_Image_' num2str(n_aggregate) '.tif']);
imwrite(Binary_Image_5,[FileName '_Binary_Image_' num2str(n_aggregate) '.tif']);
imwrite(Manual_Edge,[FileName '_Edge_Image_' num2str(n_aggregate) '.tif']);
imwrite(FinalImposedImage,[FileName '_Imposed_Image_' num2str(n_aggregate) '.tif']);
%}

end
