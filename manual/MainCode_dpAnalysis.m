%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Executive code for analyzing TEM images produced by TEM, V.1.   %%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono  %%%
%%%% The University of British Columbia, Vanouver, BC, Canada           %%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

%%%%% USE THIS CODE FOR PRIMARY PARTICLE SIZING

%% Clearing data and closing open windows
clear all;
clc;
close all;  % Close all figure windows except those created by imtool.
imtool close all;   % Close all figure windows created by imtool.
workspace;  % Make sure that the workspace panel is showing
fontSize = 10;

%% Housekeeping
global mainfolder Processing_im Im_Dir report_txt report_num FileName
report_txt = cell(1,1);

report_title = {'Image_ID','Primary Width (nm)','Primary Length (nm)',...
    'Primary eq. d (nm)','Primary Area Based on LW average(nm^2)',...
    'Primary Particle_Count','Particle Width (nm)','Particle Length (nm)',...
    'Particle Area (nm^2)','Particle eq. Da','Particle Perimeter (nm)',...
    'Radius of Gyration','Particle Type','Image_ref_number',...
    'Max res.','Cropped image reference'};

%% Getting image file location and name
image_sel = 0;
mainfolder = cd;
while image_sel == 0
    clear Im_Dir
    %% Default Value
%     if exist('default_dpda_setting.mat','file')==2
%         load('default_dpda_setting.mat','Im_Dir','mainfolder');
%     else
        
        addpath(mainfolder);
        Im_Dir = cd;
%     end
    %% Importing figures by user
    message = sprintf('Please choose image(s) to be analyzed.\nIt is recommended to choose one image per program debugging.');
    uiwait(msgbox(message));
    [Img_files,Im_Dir] = uigetfile({'*.tif;*.jpg','TEM image (*.tif;*.jpg)'},...
        'Select Images',Im_Dir,'MultiSelect', 'on');
    image_sel=Img_files;
    if iscell(Img_files) == 1 % Handling for 1 image selection
        Img_files = Img_files';
    elseif isempty(Img_files) == 1
        error('No image was selected');
    end
    if image_sel == 0
        % No image is selected
        choise=questdlg('No image was selected! Do you want to try again?', ...
            'Error','Yes','No. Quit debugging','Yes');
        if strcmp(choise,'No. Quit debugging')
            uiwait(msgbox('No image was selected and user decided to quit debugging'))
            error('No image was selected and user decided to quit debugging');
        end
    end
end

% if exist('default_dpda_setting.mat','file')==2
%     save('default_dpda_setting.mat','Im_Dir','-append');
% else
%     save('default_dpda_setting.mat','Im_Dir','mainfolder');
% end

%%  Image Processing Steps
global Cropped_im Binary_Image_3

[num_img,~] = size(Img_files);
particle_count = 0;
tot_primary = 0;

% global Thresh_slider_in

for k = 1:num_img
    
    %% Step1: Loading processing image
    cd(Im_Dir);
    if exist('Output','dir') ~= 7 %checking wheter the Output folder is available 
        mkdir('Output')
    end
    if num_img == 1
        FileName = char(Img_files);
    else
        FileName = char(Img_files(k,1));
    end
    
    Processing_im = imread(FileName);
    
    cd(mainfolder)
    
    %% Step1-1: Detecting Magnification and TEM_pix_size
    choise = questdlg('Where was this image taken?','Image source',...
        'UBC (after 2013) -> Automatic detection of magnification size',...
        'UBC (before 2013) -> Automatic detection of magnification size',...
        'Others -> Manual detection of magnification size',...
        'UBC (after 2013) -> Automatic detection of magnification size');

    if strcmp(choise,'UBC (after 2013) -> Automatic detection of magnification size')
        pixsize = TEM_pix_size2013(mainfolder);
    elseif strcmp(choise,'UBC (before 2013) -> Automatic detection of magnification size')
        pixsize = TEM_pix_size(mainfolder);
    elseif strcmp(choise,'Others -> Manual detection of magnification size')
        uiwait(msgbox('Please crop the image close enough to the magnification bar.'))
        mag_crop = imcrop(Processing_im);
        close (gcf);
        clear choise
        imshow(mag_crop);
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
        hold on
        uiwait(msgbox('Please select two points on the image that coresponds to the length of the magnification bar'));
        [x_mag, y_mag] = ginput(2);
        bar_l = abs(x_mag(2)-x_mag(1));
        line ([x_mag(1),x_mag(2)],[y_mag(1),y_mag(1)],'linewidth', 3);
        dlg_title1='Length of the magnification bar';
        promt1 = {'Please insert the length of the magnification bar in nm:'};
        num_lines1 = 1;
        def1 = {'100'};  %default value for user input
        bar_size = str2double(cell2mat(inputdlg(promt1,dlg_title1,num_lines1,def1))); %user input execution
        clear num_lines1 dlg_title1 promt1 def1
        pixsize=bar_size/bar_l;
        hold off
        close all
    end
    
    imshow(Processing_im);
    title('Processing Image', 'FontSize', fontSize);
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    
    %% Step2: Asking user about the number of the aggregates which will be analyzed
    
    %% Step3: Analyzing each aggregate
    
    particle_count = particle_count+1;

    %% Step3-2: Saving Cropped image

    %% Step3-3: Particle type selection
    Particle_Type = 3;

    %% Step3-4: Image refinment

    %% Step3-5-1: Setting coordinate system origin

    %% Step3-5-2: Setting titles
    title_measurement = 'Single particle';

    %% Step3-5-3: Computing particles dimentions
    continuing_parameter = 4;
    m = 0;
    num_primary = 0;
    crop_count=0;
    crop_ref(1)=1;
    while continuing_parameter == 1 || continuing_parameter==2 || continuing_parameter == 4

        m = m+1;
        num_primary = m
        
       %% Step3-1:  Cropping image
       if continuing_parameter==2 || continuing_parameter==4
            uiwait(msgbox('Please crop the image. For best performance, it is necessary to remove image titles, header and footer. Do NOT crop the image so close to the aggregate bounary. Double click when finish',...
                ['Process Stage: Crooping Image' num2str(1)...
                '/' num2str(1)],'help'));
            close all
            imshow(Processing_im)
            Cropped_im = imcrop(Processing_im);
           %% Step3-5: Particle sizing (dp for aggregate; particle size for others)
            imshow(Cropped_im);
            hold on
       end

        %%
        uiwait(msgbox(['Please select two points on the image that coresponds to the length of the ' title_measurement ],...
        ['Process Stage: Length of' title_measurement ' ' num2str(m)...
        '/' num2str(num_primary)],'help'));

         [x, y] = ginput(2);

         length(m,1) = pixsize*sqrt((x(2)-x(1))^2+(y(2) - y(1))^2);
         line ([x(1),x(2)],[y(1),y(2)], 'linewidth', 3);

%          uiwait(msgbox(['Please select two points on the image that coresponds to the width of the ' title_measurement ],...
%          ['Process Stage: Width of' title_measurement ' ' num2str(m)...
%          '/' num2str(num_primary)],'help'));

         [a, b] = ginput(2);

         width(m,1) = pixsize*sqrt((a(2)-a(1))^2+(b(2) - b(1))^2);
         line ([a(1),a(2)],[b(1),b(2)],'Color', 'r', 'linewidth', 3);

         % Computing particle position and its alignment
         %
         clear a b x y
         
         %%
         choise = questdlg('Do you want to analyse another particle ?',...
         'Continue?','Yes. Use previously cropped image','Yes. BUT crop the image again','No','Yes. Use previously cropped image');
         if strcmp(choise,'Yes. Use previously cropped image')
             continuing_parameter = 1;
             crop_ref(m+1,1)=crop_count+1;
         elseif strcmp(choise,'Yes. BUT crop the image again')
             continuing_parameter = 2;
             crop_count=crop_count+1;
             crop_ref(m+1,1)=crop_count+1;
             %% Saving results
             cd (Im_Dir)
             cd ('Output')
             saveas(gcf,[FileName '_Primary_L_W_' num2str(crop_count) '.tif'])
             close all
             cd (mainfolder)
         elseif strcmp(choise,'No')
             continuing_parameter = 3;
              %% Saving results
             cd (Im_Dir)
             cd ('Output')
             saveas(gcf,[FileName '_Primary_L_W_' num2str(crop_count+1) '.tif'])
             close all
             cd (mainfolder)
         end
    end

    %% Step3-5-4: Computing aggregate dimentions/parameters

    %% recording report
    tot_primary=tot_primary+1;

    Aggregate_Area=NaN;
    Aggregate_perimeter=NaN;
    A_width=NaN;
    A_length=NaN;
    Radius_Gyration=NaN;

    if num_primary>1
        report_num(tot_primary:tot_primary+num_primary-1,1)=width;
        report_num(tot_primary:tot_primary+num_primary-1,2)=length;
        report_num(tot_primary:tot_primary+num_primary-1,3)=(width+length)/2;
        report_num(tot_primary:tot_primary+num_primary-1,4)=pi/4*width.*length;
        report_num(tot_primary:tot_primary+num_primary-1,5)=num_primary;
%                 report_num(tot_primary:tot_primary+num_primary-1,4)=x_center;
%                 report_num(tot_primary:tot_primary+num_primary-1,5)=y_center;
%                 report_num(tot_primary:tot_primary+num_primary-1,6)=alignment;
        report_num(tot_primary:tot_primary+num_primary-1,6)=A_width;
        report_num(tot_primary:tot_primary+num_primary-1,7)=A_length;
        report_num(tot_primary:tot_primary+num_primary-1,8)=Aggregate_Area;
        report_num(tot_primary:tot_primary+num_primary-1,9)=sqrt(4*Aggregate_Area/pi);
        report_num(tot_primary:tot_primary+num_primary-1,10)=Aggregate_perimeter;
        report_num(tot_primary:tot_primary+num_primary-1,11)=Radius_Gyration;
        report_num(tot_primary:tot_primary+num_primary-1,12)=Particle_Type;
        report_num(tot_primary:tot_primary+num_primary-1,13)=NaN;
        report_num(tot_primary:tot_primary+num_primary-1,14)=pixsize;
        report_num(tot_primary:tot_primary+num_primary-1,15)=crop_ref;
        report_txt(tot_primary:tot_primary+num_primary-1,1)={FileName};
    else
        report_num(tot_primary,1)=width;
        report_num(tot_primary,2)=length;
        report_num(tot_primary,3)=(width+length)/2;
        report_num(tot_primary,4)=pi/4*width.*length;
        report_num(tot_primary,5)=num_primary;
        report_num(tot_primary,6)=A_width;
        report_num(tot_primary,7)=A_length;
        report_num(tot_primary,8)=Aggregate_Area;
        report_num(tot_primary,9)=sqrt(4*Aggregate_Area/pi);
        report_num(tot_primary,10)=Aggregate_perimeter;
        report_num(tot_primary,11)=Radius_Gyration;
        report_num(tot_primary,12)=Particle_Type;
        report_num(tot_primary,13)=NaN;
        report_num(tot_primary:tot_primary+num_primary-1,14)=pixsize;
        report_num(tot_primary:tot_primary+num_primary-1,15)=crop_ref;
        report_txt(tot_primary,1)={FileName};
    end
    tot_primary=tot_primary+num_primary-1;

    %% Autobackup

    cd(Im_Dir)
    cd('Output')
    if exist('Report_dpda.mat','file')==2
        save('Report_dpda.mat','report_num','report_txt','-append');
    else
        save('Report_dpda.mat','report_num','report_txt','report_title');
    end

    cd(mainfolder)

    clear length width A_length A_width


end

    %% Writing Excel Report
    
    cd(Im_Dir)
    cd('Output')
    
    if exist('Final_dpda_Report.xls','file')==2
        [datanum ~]=excellimport('Final_dpda_Report.xls',2);
        starting_row=size(datanum,1)+2;
        xlswrite('Final_dpda_Report.xls',report_txt,'TEM_ImageProcessingData',['A' num2str(starting_row)]);
        xlswrite('Final_dpda_Report.xls',report_num,'TEM_ImageProcessingData',['B' num2str(starting_row)]);
    else
        xlswrite('Final_dpda_Report.xls',report_title,'TEM_ImageProcessingData','A1');
        xlswrite('Final_dpda_Report.xls',report_txt,'TEM_ImageProcessingData','A2');
        xlswrite('Final_dpda_Report.xls',report_num,'TEM_ImageProcessingData','B2');
    end
    
    cd(mainfolder)

clear k l mainfolder num_image num_primary particle_count...
    pixsize starting_row title_measurement tot_primary width Processing_im
