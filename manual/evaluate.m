%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Executive code for analyzing TEM images produced by TEM, V.1.   %%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono  %%%
%%%% The University of British Columbia, Vanouver, BC, Canada           %%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

%%%%% USE THIS CODE TO MEASURE MORPHOLOGY PARAMETERS OF AGGREGATES AND 
%%%%% PRIMARY PARTICLES WITHING AGGREGATES. IF ONLY INTERESTED IN PRIMARY
%%%%% PARTICLE SIZING USE MainCode_dpAnalysis.m


%% Clearing data and closing open windows
clear all;
clc;  % Clear command window
close all;  % Close all figure windows except those created by imtool.
imtool close all;   % Close all figure windows created by imtool.
workspace;  % Make sure that the workspace panel is showing
fontSize = 10;

%% Housekeeping
global mainfolder img Im_Dir report_txt report_num FileName
report_txt = cell(1,1);

Extra_function = 0; % 0: No extra function 1: with extra function

%% report title
report_title = {'Image_ID','Primary Width (nm)','Primary Length (nm)',...
    'Primary eq. d (nm)','Primary Area Based on LW average(nm^2)',...
    'Primary Particle_Count','Particle Width (nm)','Particle Length (nm)',...
    'Particle Area (nm^2)','Particle eq. Da','Particle Perimeter (nm)',...
    'Radius of Gyration','Particle Type','Image_ref_number',...
    'Max res.','Cropped image ref'};

%% Getting image file location and name
image_sel = 0;
mainfolder = cd;
while image_sel == 0 % loop will repeat until image is selected or user has quit
    clear Im_Dir
    addpath(mainfolder);
    Im_Dir = cd;

    %% Importing figures by user
    message = sprintf('Please choose image(s) to be analyzed.\nIt is recommended to choose one image per program debugging.');
    uiwait(msgbox(message)); % User must click 'ok' to continue
    [Img_files,Im_Dir] = uigetfile({'*.tif;*.jpg','TEM image (*.tif;*.jpg)'},...
        'Select Images',Im_Dir,'MultiSelect', 'on'); % allow user to browse for file
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

%%  Image Processing Steps
global Cropped_im Binary_Image_3

[num_img,~] = size(Img_files); % count how many files the user has chosen
particle_count = 0;
tot_primary = 0;

% global Thresh_slider_in

for k = 1:num_img % run loop as many times as images selected
    
    %% Step1: Loading processing image
    cd(Im_Dir); % set file directory to folder image was taken from
    
    if num_img == 1
        FileName = char(Img_files); 
    else
        FileName = char(Img_files(k,1));
    end
    
    img = imread(FileName);
    
    cd(mainfolder)
    
    %img = rgb2gray(img);
    %% Step1-1: Detecting Magnification and TEM_pix_size
%     t0.RawImage = img;
%     pixsize = get_footer_scale(t0);
    
    choise = questdlg('Where was this image taken?','Image source',...
        'UBC (after 2013) -> Automatic detection of magnification size',...
        'UBC (before 2013) -> Automatic detection of magnification size',...
        'Others -> Manual detection of magnification size',...
        'UBC (after 2013) -> Automatic detection of magnification size'); % ask where photo was taken in order to determine magnification
    
    if strcmp(choise,'UBC (after 2013) -> Automatic detection of magnification size')
        pixsize = TEM_pix_size2013(mainfolder); % automatically determine magnification
    elseif strcmp(choise,'UBC (before 2013) -> Automatic detection of magnification size')
        pixsize = TEM_pix_size(mainfolder); % automatically determine magnification
    elseif strcmp(choise,'Others -> Manual detection of magnification size') % manually determine magnification
        uiwait(msgbox('Please crop the image close enough to the magnification bar.'))
        mag_crop = imcrop(img); % crop image
        close (gcf);
        clear choise
        imshow(mag_crop); % Show cropped image.
        set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
        hold on
        uiwait(msgbox('Please select two points on the image that coresponds to the length of the magnification bar'));
        [x_mag, y_mag] = ginput(2); % user chooses two point on the edge of magnification bar
        bar_l = abs(x_mag(2)-x_mag(1)); % calculate number of pixels of magnification bar
        line ([x_mag(1),x_mag(2)],[y_mag(1),y_mag(1)],'linewidth', 3);
        dlg_title1='Length of the magnification bar'; % ask for the length the magnification bar represents
        promt1 = {'Please insert the length of the magnification bar in nm:'};
        num_lines1 = 1;
        def1 = {'100'};  %default value for user input
        bar_size = str2double(cell2mat(inputdlg(promt1,dlg_title1,num_lines1,def1))); %user input execution
        clear num_lines1 dlg_title1 promt1 def1
        pixsize=bar_size/bar_l; %find the nanometers per pixel
        hold off
        close all
    end

    imshow(img);
    title('Processing Image', 'FontSize', fontSize);
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
    
    %% Step3: Analyzing each aggregate
    continuing_aggregate=1;
    l=0;
    n_aggregate=0;
    while continuing_aggregate~=0
%     for l = 1:n_aggregate
        l=l+1;
        n_aggregate=n_aggregate+1;
        particle_count = particle_count+1;
        
        %% Step3-1:  Cropping image
        uiwait(msgbox('Please crop the image. For best performance, it is necessary to remove image titles, header and footer. Do NOT crop the image so close to the aggregate boundary. Double click when finish',...
            ['Process Stage: Cropping Image' num2str(l)...
            '/' num2str(n_aggregate)],'help'));

        Cropped_im = imcrop(img);
        
        %% Step3-2: Saving Cropped image
        close (gcf);
        clear choise
        
        cd '../data'

        if exist('ManualOutput','dir') ~= 7 %checking whether the Output folder is available 
            mkdir('ManualOutput') %make output folder
        end

        cd('ManualOutput')
        imwrite(Cropped_im,[FileName '_CroppedImage_' num2str(l) '.tif']) %save cropped image as a .tif file
        cd(mainfolder)
        %% Step3-3: Particle type selection
        %% describe types
        choise = questdlg('Selec Particle Type:',...
                'Particle Type','Aggregate',...
                'Aggregate (dp measurement only)','Single primary particle','Aggregate'); 

        if strcmp(choise,'Aggregate')
            Particle_Type = 1;
        elseif strcmp(choise,'Aggregate (dp measurement only)')
            Particle_Type = 2;
            agg_primary=1;
        elseif strcmp(choise,'Single primary particle')
            Particle_Type = 3;
            agg_primary=1;
        end
        
        %% Step3-4: Image refinment
        if Particle_Type == 1
            global Thresh_slider_in Refined_surf_im
            %% Step3-4-1: Apply Lasso tool
            [binaryImage,xy_lasso,x_lasso,y_lasso,burnedImage,maskedImage] = Lasso_fun(Cropped_im);
            
            %% Step3-4-2: Refining background brightness
            [Refined_surf_im] = Background_fun(binaryImage,Cropped_im);
            
            cd(mainfolder)
            cd('../data/ManualOutput')
            save Imdata.mat Cropped_im binaryImage burnedImage ...
                maskedImage Refined_surf_im...
                xy_lasso x_lasso y_lasso
            cd(mainfolder)
            save Imdirectory.mat Im_Dir mainfolder

            %% Step3-4-3 Applying thresholding. Part 1
            % uicontrol reference page
            
            Thresh_slider_in = Refined_surf_im;
            f = figure;
            hax = axes('Units','pixels');
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            imshow(Thresh_slider_in);
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
            % global  Filtered_Image_2
            level = graythresh(Thresh_slider_in);
            % Add a slider uicontrol
            hst = uicontrol('Style', 'slider',...
                'Min',0-level,'Max',1-level,'Value',.5-level,...
                'Position', [140 480 120 20],...
                'Callback', {@Thresh_Slider});
            get(hst,'value')
            % Slider function handle callback
            % Implemented as a local function
            
            % Add a text uicontrol to label the slider
            uicontrol('Style','text',...
                'Position', [140 500 120 20],...
                'String','Threshold level')
            
            % Pause debugging while the user is performing thresholding on
            % the image by moving the slider
            h = uicontrol('Position',[100 350 200 40],'String','Continue',...
                'Callback','uiresume(gcbf)');
            message = sprintf('Move the slider to right or left to change threshold level\nWhen done, click on continute to return to main program');
            uiwait(msgbox(message));
            disp('Debugging is paused for user to apply thresholding on the image');
            uiwait(gcf); 
            disp('Thresholding is applied');
            close(f);
            
            cd(mainfolder)
            cd('../data/ManualOutput')
            load Thresh1.mat
            Binary_im_slider = Binary_Image_4;
            clear Binary_Image_4;
            cd(mainfolder)

            %% Step3-4-4 Applying thresholding. Part 2
            [Final_Binary, Final_Edge, Final_imposed] = Thresh_refine(Binary_im_slider,Thresh_slider_in,Im_Dir,FileName,n_aggregate);
            cd(mainfolder)
            cd('../data/ManualOutput')
            save Imdata.mat Cropped_im binaryImage Refined_surf_im ...
                Final_Binary Final_Edge Final_imposed Binary_im_slider ...
                xy_lasso x_lasso y_lasso
            cd(mainfolder)
            
            %%%% Asking user if he/she wants to analyse primary particles
            %%%% or not
            choise = questdlg('Do you want to measure primary particle size',...
                'Primary particle sizing?','Yes',...
                'No','Yes'); 
            if strcmp(choise,'Yes')
                agg_primary = 1;
            elseif strcmp(choise,'No')
                agg_primary = 2;
            end
            
        end
        
        %% Step3-5: Particle sizing (dp for aggregate; particle size for others)
        imshow(Cropped_im);
        uiwait(msgbox('Please crop the image for primary particle sizing.'))
        Cropped_im_primary = imcrop(Cropped_im);
        close (gcf);
        imshow(Cropped_im_primary)
        
        
        hold on
        
        %% Step3-5-2: Setting titles
        if Particle_Type < 3
            title_measurement = 'Primary particle';
        else
            title_measurement = 'Single particle';
        end
        
        %% Step3-5-3: Computing particles dimentions
        continuing_parameter = 2;
        m = 0;
        num_primary = 0;
        while agg_primary == 1 && continuing_parameter ~= 3
            
            m = m+1;
            num_primary = m
            
            uiwait(msgbox(['Please select two points on the image that correspond to the length of the ' title_measurement ],...
            ['Process Stage: Length of' title_measurement ' ' num2str(m)...
            '/' num2str(num_primary)],'help'));

             [x, y] = ginput(2);

             length(m,1) = pixsize*sqrt((x(2)-x(1))^2+(y(2) - y(1))^2);
             line ([x(1),x(2)],[y(1),y(2)], 'linewidth', 3);

             [a, b] = ginput(2);

             width(m,1) = pixsize*sqrt((a(2)-a(1))^2+(b(2) - b(1))^2);
             line ([a(1),a(2)],[b(1),b(2)],'Color', 'r', 'linewidth', 3);
             
             % Save center coordinate for this primary particle
             centers(m,:) = find_centers(x,y,a,b);  % TODO: Test this
             
             %
             clear a b x y
             
             %%%%
             if Particle_Type < 3
                 choise = questdlg('Do you want to analyse another primary particle ?',...
                 'Continue?','Yes','No','Yes');
                 if strcmp(choise,'Yes')
                     continuing_parameter = 1;
                 else
                     continuing_parameter = 3;
                 end
             else
                 continuing_parameter = 3;
             end
        end
        
%         clear a b x y
        %% Saving results
        cd(mainfolder)
        cd('../data/ManualOutput')
        saveas(gcf,[FileName '_Primary_L_W_' num2str(l) '.tif'])
        close all
        cd (mainfolder)
        
        %% Step3-5-4: Computing aggregate dimentions/parameters
        if Particle_Type == 1
            
            %% Calculating Aggregate Area
            % to determine the total area of the agglomerate
            area_pixelcount = nnz(Final_Binary);
            Aggregate_Area = area_pixelcount*pixsize^2;

            %% Calculating Aggregate Perimeter
            % to determine an estimate of the perimeter of the particle
            Aggregate_perimeter = Perimeter_Length(Final_Binary,pixsize,area_pixelcount);

            %% Calculating Aggregate Length and Width
            %to determine the length and width of the agglomerate
            [A_length, A_width] = Agg_Dimension(mainfolder,Im_Dir,Final_Edge,FileName,pixsize,l);

            %% Calculating Radius of Gyration
            [Radius_Gyration] = Gyration(Final_Binary, pixsize);

        end
        
        %% recording report
        tot_primary=tot_primary+1;
        
        if Particle_Type==2
            Aggregate_Area=NaN;
            Aggregate_perimeter=NaN;
            A_width=NaN;
            A_length=NaN;
            Radius_Gyration=NaN;
        end
        
        if Particle_Type<3
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
                report_num(tot_primary:tot_primary+num_primary-1,13)=l;
                report_num(tot_primary:tot_primary+num_primary-1,14)=pixsize;
                report_txt(tot_primary:tot_primary+num_primary-1,1)={FileName};
                tot_primary=tot_primary+num_primary-1;
            elseif num_primary==1
                report_num(tot_primary,1)=width;
                report_num(tot_primary,2)=length;
                report_num(tot_primary,3)=(width+length)/2;
                report_num(tot_primary,4)=pi/4*width.*length;
                report_num(tot_primary,5)=num_primary;
%                 report_num(tot_primary,4)=x_center;
%                 report_num(tot_primary,5)=y_center;
%                 report_num(tot_primary,6)=alignment;
                report_num(tot_primary,6)=A_width;
                report_num(tot_primary,7)=A_length;
                report_num(tot_primary,8)=Aggregate_Area;
                report_num(tot_primary,9)=sqrt(4*Aggregate_Area/pi);
                report_num(tot_primary,10)=Aggregate_perimeter;
                report_num(tot_primary,11)=Radius_Gyration;
                report_num(tot_primary,12)=Particle_Type;
                report_num(tot_primary,13)=l;
                report_num(tot_primary,14)=pixsize;
                report_txt(tot_primary,1)={FileName};
            elseif num_primary==0
                report_num(tot_primary,1)=NaN;
                report_num(tot_primary,2)=NaN;
                report_num(tot_primary,3)=NaN;
                report_num(tot_primary,4)=NaN;
                report_num(tot_primary,5)=num_primary;
%                 report_num(tot_primary,4)=x_center;
%                 report_num(tot_primary,5)=y_center;
%                 report_num(tot_primary,6)=alignment;
                report_num(tot_primary,6)=A_width;
                report_num(tot_primary,7)=A_length;
                report_num(tot_primary,8)=Aggregate_Area;
                report_num(tot_primary,9)=sqrt(4*Aggregate_Area/pi);
                report_num(tot_primary,10)=Aggregate_perimeter;
                report_num(tot_primary,11)=Radius_Gyration;
                report_num(tot_primary,12)=Particle_Type;
                report_num(tot_primary,13)=l;
                report_num(tot_primary,14)=pixsize;
                report_txt(tot_primary,1)={FileName};
            end
        else
            report_num(tot_primary,1)=NaN;
            report_num(tot_primary,2)=NaN;
            report_num(tot_primary,3)=NaN;
            report_num(tot_primary,4)=NaN;
            report_num(tot_primary,5)=NaN;
%             report_num(tot_primary,4)=x_center;
%             report_num(tot_primary,5)=y_center;
%             report_num(tot_primary,6)=alignment;
            report_num(tot_primary,6)=width;
            report_num(tot_primary,7)=length;
            report_num(tot_primary,8)=NaN;
            report_num(tot_primary,9)=(width+length)/2;
            report_num(tot_primary,10)=NaN;
            report_num(tot_primary,11)=NaN;
            report_num(tot_primary,12)=Particle_Type;
            report_num(tot_primary,13)=l;
            report_num(tot_primary,14)=pixsize;
            report_txt(tot_primary,1)={FileName};
            
        end
        
        %% Autobackup
        
        cd(mainfolder)
        cd('../data/ManualOutput')
        if exist('Report_dpda.mat','file')==2
            save('Report_dpda.mat','report_num','report_txt','-append');
        else
            save('Report_dpda.mat','report_num','report_txt','report_title');
        end
        
        cd(mainfolder)
        
%         clear length width A_length A_width x_center y_center alignment 
        clear length width A_length A_width 
        
        
        choise = questdlg('Do you want to analyse another aggregate ?',...
            'Continue?','Yes','No','Yes');
        if strcmp(choise,'Yes')
            continuing_aggregate = 1;     
        else
            continuing_aggregate = 0;
        end
        
        
    end
    

end

%% Writing Excel Report

cd(mainfolder)
cd('../data/ManualOutput')

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

clear k l mainfolder n_aggregate num_image num_primary particle_count...
    pixsize starting_row title_measurement tot_primary width img
