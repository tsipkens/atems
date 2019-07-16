
% EVALUATE  
%   Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono  %%%
%	The University of British Columbia, Vanouver, BC, Canada
%	If you use this code or any modified version of it, you are expected
%	to refere to the the main developers and appropriate articles, e.g. 
%	"Observations of a Correlation between Primary Particle and Aggregate
%	Size for Soot Particles", J. of Aerosol Sci. & Tech.

%	USE THIS CODE TO MEASURE MORPHOLOGY PARAMETERS OF AGGREGATES AND 
%	PRIMARY PARTICLES WITHING AGGREGATES. IF ONLY INTERESTED IN PRIMARY
%	PARTICLE SIZING USE MainCode_dpAnalysis.m
%=========================================================================%

function [] = evaluate(img)

%-- Report title ---------------------------------------------------------%
report_title = {'Image_ID','Primary Width (nm)','Primary Length (nm)',...
    'Primary eq. d (nm)','Primary Area Based on LW average(nm^2)',...
    'Primary Particle_Count','Particle Width (nm)','Particle Length (nm)',...
    'Particle Area (nm^2)','Particle eq. Da','Particle Perimeter (nm)',...
    'Radius of Gyration','Particle Type','Image_ref_number',...
    'Max res.','Cropped image ref'};
mainfolder = cd;
particle_count = 0;
tot_primary = 0;


for kk = 1:img.num % run loop as many times as images selected
    
    %== Step 1: Image preparation ========================================%
    %-- Step 1-1: Loading images one-by-one ------------------------------%
    % cd(img.dir); % change active directory to image directory
    if img.num == 1
        fname = char(img.fname); 
    else
        fname = char(img.fname(img_counter,1));
    end
    img.RawImage = imread([img.dir,fname]); % read in image
    
    %-- Step 1-3: Crop footer and get scale from footer ------------------%
    [img,pixsize] = tools.get_footer_scale(img);
    img_cropped = img.Cropped;
    
    
    %== Step 3: Analyzing each aggregate =================================%
    continuing_aggregate = 1;
    ll = 0;
    n_aggregate = 0;
    while continuing_aggregate~=0
        ll = ll+1;
        n_aggregate=n_aggregate+1;
        particle_count = particle_count+1;
        
        %== Step 3-3: Particle type selection ============================%
        choice = questdlg('Select Particle Type:',...
                'Particle Type','Aggregate',...
                'Aggregate (dp measurement only)','Single primary particle','Aggregate'); 

        if strcmp(choice,'Aggregate')
            Particle_Type = 1;
        elseif strcmp(choice,'Aggregate (dp measurement only)')
            Particle_Type = 2;
            agg_primary=1;
        elseif strcmp(choice,'Single primary particle')
            Particle_Type = 3;
            agg_primary=1;
        end
        
        %== Step 3-4: Image refinment ====================================%
        if Particle_Type == 1
            
            %-- Step 3-4-3: Applying thresholding. Part 1 ----------------%
            [binary_cropped,~,Thresh_slider_in] = thresholding_ui.Agg_det_Slider(img.Cropped,0);
            binaryImage = ~binary_cropped;
            
            [~, Final_Edge,~] = manual.Thresh_refine(binaryImage,...
                Thresh_slider_in,img.fname{kk},n_aggregate);
            

            %-- Step3-4-4: Applying thresholding. Part 2 -----------------%
            cd(mainfolder)
            cd('data/ManualOutput')
            save Imdata.mat Cropped_im binaryImage
            cd(mainfolder)
            
            %-- Ask user if they want to analyse primary particles or not
            choice = questdlg('Do you want to measure primary particle size',...
                'Primary particle sizing?','Yes',...
                'No','Yes'); 
            if strcmp(choice,'Yes')
                agg_primary = 1;
            elseif strcmp(choice,'No')
                agg_primary = 2;
            end
            
        end
        
       %== Step 3-5: Particle sizing (dp for aggregate; particle size for others)
        if agg_primary==1 
            imshow(img_cropped);
            uiwait(msgbox('Please crop the image for primary particle sizing.'))
            Cropped_im_primary = imcrop(img_cropped);
            close (gcf);
            imshow(Cropped_im_primary)
            hold on
        end
        
        %-- Step 3-5-2: Setting titles -----------------------------------%
        if Particle_Type < 3
            title_measurement = 'Primary particle';
        else
            title_measurement = 'Single particle';
        end
        
        %-- Step 3-5-3: Computing particles dimentions -------------------%
        continuing_parameter = 2;
        m = 0;
        num_primary = 0;
        while agg_primary == 1 && continuing_parameter ~= 3
            
            m = m+1;
            num_primary = m;
            
            uiwait(msgbox(['Please select two points on the image that correspond to the length of the ' title_measurement ],...
            ['Process Stage: Length of' title_measurement ' ' num2str(m)...
            '/' num2str(num_primary)],'help'));

             [x, y] = ginput(2);

             length(m,1) = pixsize*sqrt((x(2)-x(1))^2+(y(2) - y(1))^2);
             line ([x(1),x(2)],[y(1),y(2)], 'linewidth', 3);

             [a, b] = ginput(2);

             width(m,1) = pixsize*sqrt((a(2)-a(1))^2+(b(2) - b(1))^2);
             line ([a(1),a(2)],[b(1),b(2)],'Color', 'r', 'linewidth', 3);
             
             %-- Save center of primary particle -------------------------%
             centers(m,:) = manual.find_centers(x,y,a,b);  % TODO: Test this
             
             clear a b x y
             
             %-- Check if there are more primary particles ---------------%
             if Particle_Type < 3
                 choice = questdlg('Do you want to analyse another primary particle ?',...
                 'Continue?','Yes','No','Yes');
                 if strcmp(choice,'Yes')
                     continuing_parameter = 1;
                 else
                     continuing_parameter = 3;
                 end
             else
                 continuing_parameter = 3;
             end
        end
        
        
        %-- Save results -------------------------------------------------%
        saveas(gcf,['data/ManualOutput/',img.fname{kk} '_Primary_L_W_' num2str(ll) '.tif'])
        close all
        
        %== Step 3-5-4: Computing aggregate dimentions/parameters ========%
        if Particle_Type == 1
            
           
            area_pixelcount = nnz(binaryImage); % number of non-zero pixels
            Aggregate_Area = nnz(binaryImage)*pixsize^2; % aggregate area
            
            Aggregate_perimeter = manual.Perimeter_Length(binaryImage,pixsize,area_pixelcount);
                % calculate aggregat perimeter
            
            %-- Calculating aggregate length and width -------------------%
            %   To determine the length and width of the agglomerate
            [A_length, A_width] = manual.Agg_Dimension(mainfolder,Final_Edge,img.fname{kk},pixsize,ll);
                % calculate aggregate length and width
            
            [Radius_Gyration] = manual.Gyration(binaryImage, pixsize);
                % calculate radius of gyration

        end
        
        %-- Prepare output -----------------------------------------------%
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
                report_num(tot_primary:tot_primary+num_primary-1,13)=ll;
                report_num(tot_primary:tot_primary+num_primary-1,14)=pixsize;
%                 report_txt(tot_primary:tot_primary+num_primary-1,1)=img.fname{kk};
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
                report_num(tot_primary,13)=ll;
                report_num(tot_primary,14)=pixsize;
%                 report_txt(tot_primary,1)=img.fname{kk};
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
                report_num(tot_primary,13)=ll;
                report_num(tot_primary,14)=pixsize;
%                 report_txt(tot_primary,1)=img.fname{kk};
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
            report_num(tot_primary,13)=ll;
            report_num(tot_primary,14)=pixsize;
%             report_txt(tot_primary,1)=img.fname{kk};
            
        end
        
        
        %-- Autobackup ----------------------------------------------------%
        if exist('data/ManualOutput/Report_dpda.mat','file')==2
            save('data/ManualOutput/Report_dpda.mat','report_num','-append');
        else
            save('data/ManualOutput/Report_dpda.mat','report_num','report_title');
        end
        
        clear length width % clear variables prior to next iteration
        
        choice = questdlg('Do you want to analyse another aggregate ?',...
            'Continue?','Yes','No','Yes');
        if strcmp(choice,'Yes')
            continuing_aggregate = 1;     
        else
            continuing_aggregate = 0;
        end
        
        
    end
    

end

%-- Write Excel report ---------------------------------------------------%
if exist('data/ManualOutput/Final_dpda_Report.xls','file')==2
    datanum=manual.excel_import('data/ManualOutput/Final_dpda_Report.xls',2);
    starting_row=size(datanum,1)+2;
    % xlswrite('data/ManualOutput/Final_dpda_Report.xls',report_txt,'TEM_ImageProcessingData',['A' num2str(starting_row)]);
    xlswrite('data/ManualOutput/Final_dpda_Report.xls',report_num,'TEM_ImageProcessingData',['B' num2str(starting_row)]);
else
    xlswrite('data/ManualOutput/Final_dpda_Report.xls',report_title,'TEM_ImageProcessingData','A1');
    % xlswrite('data/ManualOutput/Final_dpda_Report.xls',report_txt,'TEM_ImageProcessingData','A2');
    xlswrite('data/ManualOutput/Final_dpda_Report.xls',report_num,'TEM_ImageProcessingData','B2');
end



end

