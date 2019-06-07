
function [] = perform_kook(img)

% Code written by Ben Gigone and Emre Karatas, PhD
% Adapted from Kook et al. 2016, SAE
% Works on Matlab 2012a or higher + Image RawImage Toolbox
%
% This code is modified by Yiling Kang at the University of British
% Columbia
% This code was subsequently modified by Timothy Sipkens at the Unversity
% of British Columbia
%
% Check README file for more documentation and information


%% Clearing data and closing open windows
close all; % close all figure windos

%% Choose appropriate value for xls_sheet based on Excel version
xls_sheet = 2; % uncomment if >= Excel 2013
% xls_sheet = 4 % uncomment if < Excel 2013


%% Sensitivity and Scaling Parameters
maximgCount = 255; % Maximum image count for 8-bit image 
SelfSubt = 0.7; % Self-subtraction level 
mf = 1; % Median filter [x x] if needed 
alpha = 0.1; % Shape of the negative Laplacian “unsharp” filter 0?1 0.1
rmax = 80; % Maximum radius in pixel %155
rmin = 30; % Minimum radius in pixel (Keep high enough to eliminate dummies) %62
sens_val = 0.939;%57; % the sensitivity (0?1) for the circular Hough transform 
edge_threshold = [0.125 0.190]; % the threshold for finding edges with edge detection


%% Excel report title
report_title = {'Image_ID','Particle Diameter (dp)(nm)','Number of Particles','Average dp (nm)','Radius of Gyration (nm)'};
extracted_text = cell(1,1);



%% Main image processing loop
for img_counter = 1:img.num % run loop as many times as images selected

    %% Loading images one by one
if img.num == 1
    FileName = char(img.files); 
else
    FileName = char(img.files(img_counter,1));
end
img.RawImage = imread(['..\Images\',FileName]);

%remove if necessary
%img.RawImage = rgb2gray(img.RawImage);
    

%% Crop footer and get scale
[img,pixsize] = tools.get_footer_scale(img);

figure();imshow(img.Cropped, []);title('Cropped Image'); % Figure 1: cropped iamge

%% Creating a new folder to store data from this image processing program
% TODO : Add new directory folder for each image and input overlayed image,
% original image, edge detection results, and histogram for each one

% checking whether output folder is available
if exist('Data\KookOutput','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('Data\KookOutput') % make output folder
end

%% Begin image processing loop! User begins by cropping one aggregate to analyze

% initializing variables
userFin = 0; % if user is finished selecting aggregates, userFin = 1

% indicates the number of aggregates that the user selected -  also insert
% this value at the end of the saved processed image names
aggNum = 0; 

while userFin == 0

%% creating new folder within folder for the individual image
[~,FName,~] = fileparts(FileName);
imgFoldName = ['Data\KookOutput\',FName,'_imgAnlys'];
if exist(imgFoldName, 'dir') ~= 7
    mkdir(imgFoldName)
end
    
%% cropping aggregate photo
uiwait(msgbox('Please crop an image of the aggregate that you wish to analyze.'));

img.Cropped_agg = imcrop(img.Cropped); % user crops aggregate
close(gcf);
imshow(img.Cropped_agg); % show cropped aggregate

aggNum = aggNum + 1;

saveas(gcf,[imgFoldName,'\cropped_',int2str(aggNum)],'tif');

%% Preprocessing %%

%% Converts cropped image to a binary image
[binary_cropped] = kook.Agg_det_Slider(img.Cropped_agg);

%% fixing background illumination
se = strel('disk',85);
II1 = imbothat(img.Cropped_agg,se);
figure
imshow(II1,[])
title('Step 1: Black Top Hat Filter'); % FIGURE 1


%% Enhance Contrast
II1 = imadjust(II1);
figure()
imshow(II1, [])
title('Step 2: Contrast Enhanced');   %FIGURE 2

%% Median Filtering

% - step 3: median filter to remove noise 
II1_mf = medfilt2(II1); %, [mf mf]); 
%figure();
imshow(II1_mf, []);
title('Step 3: Median filter'); % FIGURE 3 

%% Saving the results of pre-processing
saveas(gcf, [imgFoldName,'\prep_',int2str(aggNum)], 'tif');

%% RawImage : Background erasing, Canny edge detection, background inversion, Circular Hough Transform

%% Erasing background by multiplying binary image with grayscale image
img.Analyze = double(binary_cropped) .* double(II1_mf);
figure();
imshow(img.Analyze, []);
title('Step 4: Background Erasing') % FIGURE 4


%% Canny Edge Detection

% Canny edge detection 
BWCED = edge(img.Analyze,'Canny',edge_threshold); 
figure();
imshow(BWCED);
title('Step 5: Canny Edge Detection'); % FIGURE 5

saveas(gcf, [imgFoldName,'\edge_',int2str(aggNum)], 'tif')

%% Imposing white background onto image so that the program does not detect any background particles

BWCED2 = double(~binary_cropped) + double(BWCED);
figure();
imshow(BWCED2);
title('Step 6: Binary Image Overlap') % FIGURE 6

%% Find and Draw Circles Within Aggregates

% Find circles within soot aggregates 
[centersCED, radiiCED, metricCED] = imfindcircles(BWCED2,[rmin rmax],...
    'ObjectPolarity', 'dark', 'Sensitivity', sens_val, 'Method', 'TwoStage'); 

% - draw circles  ----- FIGURE 7 -------
figure();
imshow(img.Cropped_agg,[]);
hold;
h = viscircles(centersCED, radiiCED, 'EdgeColor','r'); 
title('Step 7: Parimary particles overlaid on the original TEM image'); 

saveas(gcf, [imgFoldName,'\',FName,'_circOrig_',int2str(aggNum)], 'tif')

% - check the circle finder by overlaying the CHT boundaries on the original image 
R = imfuse(BWCED2, img.Cropped_agg,'blend'); 

% -------- FIGURE 8 ---------
figure();imshow(R,[],'InitialMagnification',500);hold;h = viscircles(centersCED, radiiCED, 'EdgeColor','r'); 
title('Step 8: Primary particles overlaid on the Canny edges and the original TEM image');

saveas(gcf, [imgFoldName,'\circAll_',int2str(aggNum)], 'tif')

%% Calculate Parameters (Add Histogram)

dpdist = radiiCED*pixsize*2;
savepics = struct('dpdist', dpdist, 'centersCED', centersCED, 'metriCED', metricCED);
save(['Data\KookOutput\saved_pictures.mat'], 'savepics'); % Save the results 


% ------- FIGURE 9 --------

figure
plot(savepics.dpdist)
hist(savepics.dpdist,10)
xlabel('Soot Diameter');
ylabel('Frequency')
set(gca, 'fontsize', 16)

saveas(gcf, [imgFoldName,'\histo_',int2str(aggNum)], 'jpg');

%% error statement to pause program for debugging purposes

%% Binarize Image (Add RoG Calculation) 
[x,y] = find(binary_cropped == 0);

%% Calculating radius of gyration

CenterOfMassXY = [mean(x); mean(y)] ;

Totaln = length(find(binary_cropped == 0));
sum = 0;
for i=1:1:Totaln
   sum = sum + (x(i) - CenterOfMassXY(1,1))^2 + (y(i)-CenterOfMassXY(2,1))^2;
end

sum = sum/Totaln;
RoG = sqrt(sum)*pixsize;
AverageRadius = mean(dpdist);
NumberofParticles = length(dpdist);

figure();
imshow(binary_cropped, []);
title('Image Binarized'); 
text(0.25 * size(binary_cropped, 1), 0.1 * size(binary_cropped, 2), sprintf('Radius of gyration = %6.2f nm', (RoG)),...
    'fontsize', 12, 'fontname','TimesNewRoman');

% binName = sprintf('%s_binary_%i', FName, aggNum);
% saveas(gcf, binName, 'jpg')

%% Saving Results
extracted_text(1) = {FileName};
extractedData(1) = NumberofParticles;
extractedData(2) = AverageRadius;
extractedData(3) = RoG;

%% Write to EXCEL and saving

% saving to mat file
if exist('Data\KookOutput\Kook_data.mat','file') == 2
    save('Data\KookOutput\Kook_data.mat','extractedData','extracted_text','dpdist','-append');
else
    save('Data\KookOutput\Kook_data.mat','extractedData','extracted_text','dpdist','report_title');
end

% loop to save each dpdist to the rest of the data
for i = 1:length(dpdist)
    
    if exist('Data\KookOutput\Kook_output_new.xls','file') == 2
        [~,sheets,~] = xlsfinfo('Data\KookOutput\Kook_output_new.xls'); % checking to see if kook_output sheet already exists
        sheetname = char(sheets(1,xls_sheet)); % choosing the second sheet
        datanum = xlsread('Data\KookOutput\Kook_output_new.xls',sheetname); % loading the data
        starting_row = size(datanum,1) + 2; % finding number of rows and then starting on the next row
        xlswrite('Data\KookOutput\Kook_output_new.xls',extracted_text,'TEM_Results',['A' num2str(starting_row)]);
        xlswrite('Data\KookOutput\Kook_output_new.xls',dpdist(i),'TEM_Results',['B' num2str(starting_row)]);
        xlswrite('Data\KookOutput\Kook_output_new.xls',extractedData,'TEM_Results',['c' num2str(starting_row)]);
        
    else
        savecounter = 1;
        xlswrite('Data\KookOutput\Kook_output_new.xls',report_title,'TEM_Results','A1');
        xlswrite('Data\KookOutput\Kook_output_new.xls',extracted_text,'TEM_Results','A2');
        xlswrite('Data\KookOutput\Kook_output_new.xls',dpdist(i),'TEM_Results','B2');
        xlswrite('Data\KookOutput\Kook_output_new.xls',extractedData,'TEM_Results','C2');
    end
end


%% checking to see if user is done analyzing aggregates
fin_choice = questdlg('Are there any more aggregates you wish to analyze?','Done?','Yes','No','Yes');

if strcmp(fin_choice,'No')
    userFin = 1;
end

end

timer = img_counter

end

close all
