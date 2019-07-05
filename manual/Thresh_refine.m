%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [Final_Binary, Final_Edge, Final_imposed] = Thresh_refine(Binary_im_slider,Thresh_slider_in,Im_Dir,FileName,n_aggregate)

global Binary_Image_5 Manual_Edge FinalImposedImage

%% Binary image via SELECTION
% to further reduce the noise, and solve the area calculation problems of
% multiple particle images

uiwait(msgbox('Please select which particle(s) wished to be analyzed.\nDouble click, or right click, or shift-click on the desired particle.\nNote that only one particle may be selected per analysis!',...
    'Process Stage: Manual Artifact Removal','help'));
Binary_Image_5 = bwselect(Binary_im_slider,8);

%% Imposed Image
% to get particle, with no background, thus eliminating the semi-large
% carbon frames in the background
% impose the inverse of Binary_Image_5 on Filtered_Image_2

Imposed_Image=imimposemin(Thresh_slider_in, ~Binary_Image_5);

%% Edge Image via Sobel
% Use Sobel's Method as a built-in edge detection function for particle's 
% outline.  Can consider using other methods (Roberts, Canny, etc)

Edge_Image = edge(Imposed_Image,'sobel');

%% Dilated Edge Image
% to strengthen the particle's outline, use dilation

SE2 = strel('disk',1);
Dilated_Edge_Image = imdilate(Edge_Image,SE2);

clear Edge_Image SE2

%% Manual Edge Image
% to get rid of large spots that are not part of the image obvious to the
% human eye.  May consider automating this process later on for cleaner
% images

pass=0;
while pass==0;
    
    uiwait(msgbox('Please LEFT click on the pixels that are clearly not part of the outline.  Push ENTER when finish.',...
        'Process Stage: Manual Edge','help'));
    temp_Edge=bwselect(Dilated_Edge_Image,4);
    close all
    Manual_Edge=Dilated_Edge_Image-temp_Edge;
    
    imshow(Manual_Edge);
    
    choise=questdlg('Do you want to repeat the Manual Edge process?',...
        'Manual Edge Clarification','Yes',...
        'No','Yes'); 
    close all
    if  strcmp(choise,'No') == 1
        pass = 1;
    end

end

clear temp_Edge Dilated_Edge

FinalImposedImage = imimposemin(Thresh_slider_in, Manual_Edge);
Final_imposed = FinalImposedImage;
Final_Binary = Binary_Image_5;
Final_Edge = Manual_Edge;
%% Saving Images
cd(mainfolder)
cd('../data')
if exist('ManualOutput','dir')~=7 %checking wheter the Output folder available 
    mkdir('ManualOutput')
end
cd('ManualOutput')

imwrite(Thresh_slider_in,[FileName '_Filtered_Image_' num2str(n_aggregate) '.tif']);
imwrite(Binary_Image_5,[FileName '_Binary_Image_' num2str(n_aggregate) '.tif']);
imwrite(Manual_Edge,[FileName '_Edge_Image_' num2str(n_aggregate) '.tif']);
imwrite(FinalImposedImage,[FileName '_Imposed_Image_' num2str(n_aggregate) '.tif']);

