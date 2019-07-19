
% EVALUATE  Performs modified Kook algorithm
%
% Code written by Ben Gigone and Emre Karatas, PhD
% Adapted from Kook et al. 2016, SAE
% Works on Matlab 2012a or higher + Image RawImage Toolbox
%
% This code is modified by Yiling Kang, Timothy Sipkens, and
% Yeshun (Samuel) Ma at the University of British Columbia
%
% Check README.txt file for more documentation and information
%=========================================================================%

function [img_data,imgs] = evaluate(imgs,bool_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end


%-- Sensitivity and Scaling Parameters -----------------------------------%
maximgCount = 255; % Maximum image count for 8-bit image 
SelfSubt = 0.7; % Self-subtraction level 
mf = 1; % Median filter [x x] if needed 
alpha = 0.1; % Shape of the negative Laplacian “unsharp” filter 0->1 0.1
rmax = 30; % Maximum radius in pixel
rmin = 4; % Minimum radius in pixel (Keep high enough to eliminate dummies)
sens_val = 0.75; % the sensitivity (0?1) for the circular Hough transform 
edge_threshold = [0.125 0.190]; % the threshold for finding edges with edge detection

img_data = struct; % initialize image data structure

%== Main image processing loop ===========================================%
for ii = 1:length(imgs) % run loop as many times as images selected

%-- Crop footer and get scale --------------------------------------------%
pixsize = imgs(ii).pixsize;

figure(); imshow(imgs(ii).Cropped, []); title('Cropped Image'); % Figure 1: cropped iamge

%-- Creating a new folder to store data from this image processing program --%
% TODO : Add new directory folder for each image and input overlayed image,
% original image, edge detection results, and histogram for each one

% checking whether output folder is available
if exist('Data\KookOutput','dir') ~= 7 % 7 if exist parameter is a directory
    mkdir('Data\KookOutput') % make output folder
end

%== Begin image processing loop ==========================================%
%-- User begins by cropping one aggregate to analyze ---------------------%

% initializing variables
userFin = 0; % if user is finished selecting aggregates, userFin = 1

ll = 0; % initialize aggregate counter

while userFin == 0
    
    ll = ll + 1; % increment aggregate counter
    
    Data = struct; % initialize data structure for current aggregate
    Data.method = 'kook_mod';
    
    
    %-- Creating new folder for the individual image ---------------------%
    folder_save_img = ['Data\KookOutput\',imgs(ii).fname,'_imgAnlys'];
    if exist(folder_save_img, 'dir') ~= 7
        mkdir(folder_save_img)
    end


    %-- Crop aggregate photo ---------------------------------------------%
    uiwait(msgbox('Please crop an image of the aggregate that you wish to analyze.'));
    
    figure;
    imgs(ii).Cropped_agg = imcrop(imgs(ii).Cropped); % user crops aggregate
    close(gcf);
    
    if bool_plot
        imshow(imgs(ii).Cropped_agg); % show cropped aggregate
        saveas(gcf,[folder_save_img,'\cropped_',int2str(ll)],'tif');
    end
    
    %== Preprocess image =================================================%
    [~,img_Canny,img_binary] = kook_mod.preprocess(imgs(ii),folder_save_img,ll,bool_plot);
    imgs(ii).Canny = img_Canny;
    
    %== Find and draw circles within aggregates ==========================%
    % Find circles within soot aggregates 
    [centers, radii] = imfindcircles(img_Canny,[rmin rmax],...
        'ObjectPolarity', 'dark', 'Sensitivity', sens_val, 'Method', 'TwoStage'); 
    Data.centers = centers;
    Data.radii = radii;
    
    
    if bool_plot % Draw circles (Figure 7)
        figure();
        imshow(imgs(ii).Cropped_agg,[]);
        hold;
        h = viscircles(centers, radii, 'EdgeColor','r'); 
        title('Step 7: Parimary particles overlaid on the original TEM image'); 
        saveas(gcf, [folder_save_img,'\',FName,'_circOrig_',int2str(ll)], 'tif')
    end


    %-- Check the circle finder by overlaying the CHT boundaries on the original image 
    %-- Remove circles out of the aggregate (?)
    R = imfuse(img_Canny,imgs(ii).Cropped_agg,'blend'); 

    % Draw modified circles (Figure 8)
    figure();imshow(R,[],'InitialMagnification',500);hold;h = viscircles(centers, radii, 'EdgeColor','r'); 
    title('Step 8: Primary particles overlaid on the Canny edges and the original TEM image');
    saveas(gcf, [folder_save_img,'\circAll_',int2str(ll)], 'tif')


    %-- Calculate Parameters (Add Histogram) -----------------------------%
    Data.dp = radii*pixsize*2;
    Data.dpg = nthroot(prod(Data.dp),1/length(Data.dp)); % geometric mean
    Data.sg = log(std(Data.dp)); % geometric standard deviation

    if bool_plot % Plot histogram (Figure 9)
        figure;
        histogram(dpdist,10);
        xlabel('Soot Diameter');
        ylabel('Frequency');
        saveas(gcf, [folder_save_img,'\histo_',int2str(ll)], 'jpg');
    end

    %-- Binarize Image (Add RoG Calculation) -----------------------------%
    [x,y] = find(img_binary == 0);


    %-- Calculating radius of gyration -----------------------------------%
    CenterOfMassXY = [mean(x); mean(y)] ;

    Totaln = length(find(img_binary == 0));
    sum = 0;
    for i=1:1:Totaln
       sum = sum + (x(i) - CenterOfMassXY(1,1))^2 + (y(i)-CenterOfMassXY(2,1))^2;
    end

    sum = sum/Totaln;
    Data.Rg = sqrt(sum)*pixsize; % radius of gyration
    Data.Np = length(Data.dp); % number of particles
    
    if bool_plot
        figure();
        imshow(img_binary, []);
        title('Image Binarized'); 
        text(0.25 * size(img_binary, 1), 0.1 * size(img_binary, 2), sprintf('Radius of gyration = %6.2f nm', (Data.Rg)),...
            'fontsize', 12, 'fontname','TimesNewRoman');
    end
    
    %== Save results =====================================================%
    %   Format output and autobackup data --------------------------------%
    img_data(ii).Agg(ll).fname = imgs(ii).fname; % store file name with data
    img_data(ii).Agg(ll).Data = Data; % copy Dp data structure into img_data
    save('Data\KookOutput\kook_data.mat','img_data'); % backup img_data
    
    close all;
    
    %{
    %-- Excel report title -----------------------------------------------%
    % report_title = {'Image_ID','Particle Diameter (dp)(nm)','Number of Particles','Average dp (nm)','Radius of Gyration (nm)'};
    % extracted_text = cell(1,1);
        
    %-- Write to EXCEL and saving ----------------------------------------%
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
    %}

    %-- Check to see if user is done analyzing aggregates --------------------%
    fin_choice = questdlg('Are there any more aggregates you wish to analyze?','Done?','Yes','No','Yes');

    if strcmp(fin_choice,'No')
        userFin = 1;
    end

end % end of aggregate loop

end % end of image loop

close all

end
