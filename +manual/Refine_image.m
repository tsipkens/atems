%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [Discard] = Refine_image( particle_number )
%Refine_image crops TEM image to the particle serounding and improve the
%image quality
%   Version: 17072012

global mainfolder Im_Dir FileName
global Cropped_im Filtered_Image_2 Binary_Image_3 Manual_Edge FinalImposedImage

Discard=0;

%% "average" filter

h = fspecial('average');
Filtered_Image_1 = imfilter(Crop_image, h);

clear h

%% median filter2
% using the median filter2 function, examine a neighborhood WxW matrix,
% take and make the centre of that matrix the median of the original
% neighborhood.  Specialized for "salt and pepper" noise.

W = 5;
Filtered_Image_2 = medfilt2(Filtered_Image_1 , [W W]);


pass=0;
adj=0;
while pass==0;
    %% Binary image via threshold value
  
    level = graythresh(Filtered_Image_2);
    
    imshow(Filtered_Image_2);
    dlg_title='Manual Threshold Control';
    promt={['Please input the adjustment for threshold level (' num2str(0-level) ' to ' num2str(1-level) '):']};
    num_lines=1;
    def={num2str(adj)};  %default value for user input
    adj=str2num(cell2mat(inputdlg(promt,dlg_title,num_lines,def))); %#ok<ST2NM> %user input execution
    
    level = level+adj; 

    Binary_Image_1 = im2bw(Filtered_Image_1,level);
    
    %% Binary image via Dilation  
    % to reduce initial noise and fill initial gaps
    SE1 = strel('square',1);
    Binary_Image_2 = imdilate(~Binary_Image_1,SE1);
    
      
    temp_image=imimposemin(Filtered_Image_2,Binary_Image_2);
    imshow(temp_image);
    
    choise=questdlg('Do you want to change the threshold level?',...
        'Manual Threshold Control','Change the threshold level',...
        'Keep the threshold level','Discard The Image','Change the threshold level'); 

    if  strcmp(choise,'Keep the threshold level')==1
        pass=1;
    elseif strcmp(choise,'Discard The Image')==1
        pass=1; Discard=1;
    end
    
end

if Discard==1
else
%% Binary image via SELECTION
% to further reduce the noise, and solve the area calculation problems of
% multiple particle images
    
uiwait(msgbox('Please select which particle(s) wished to be analyzed.\nDouble click, or right click, or shift-click on the desired particle.\nNote that only one particle may be selected per analysis!',...
    'Process Stage: Manual Artifact Removal','help'));
    
Binary_Image_3 = bwselect(Binary_Image_2,8);

clear Filtered_Image_1 Binary_Image_1 Binary_Image_2


%% Imposed Image
% to get particle, with no background, thus eliminating the semi-large
% carbon frames in the background
% impose the inverse of Binary_Image_3 on Filtered_Image_2

Imposed_Image=imimposemin(Filtered_Image_2, ~Binary_Image_3);

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
    
    imshow(Manual_Edge)
    
    choise=questdlg('Do you want to repeat the Manual Edge process?',...
        'Manual Edge Clarification','Yes',...
        'No','Yes'); 
    close all
    if  strcmp(choise,'No')==1
        pass=1;
    end

end


clear temp_Edge Dilated_Edge

FinalImposedImage=imimposemin(Crop_image, Manual_Edge);

%% Saving Images
cd(mainfolder)
cd('../data')

if exist('ManualOutput','dir')~=7 %checking wheter the Output folder available 
    mkdir('ManualOutput')
end

cd('ManualOutput')


imwrite(Filtered_Image_2,[FileName '_Filtered_Image_' num2str(particle_number) '.tif'])
imwrite(Binary_Image_3,[FileName '_Binary_Image_' num2str(particle_number) '.tif'])
imwrite(Manual_Edge,[FileName '_Edge_Image_' num2str(particle_number) '.tif'])
imwrite(FinalImposedImage,[FileName '_Imposed_Image_' num2str(particle_number) '.tif'])


end
cd(mainfolder);    


end

