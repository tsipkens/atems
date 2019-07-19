
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

function [Agg] = evaluate(imgs,bool_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end

Agg = struct;

particle_count = 0;
tot_primary = 0;

Agg = struct;
ll = 0; % initialize aggregate counter

for ii = 1:length(imgs) % run loop as many times as images selected
    
    %== Step 1: Image preparation ========================================%
    %-- Step 1-3: Crop footer and get scale from footer ------------------%
    pixsize = imgs(ii).pixsize;
    
    
    %== Step 3: Analyzing each aggregate =================================%
    continuing_aggregate = 1;
    jj = 0;
    
    while continuing_aggregate~=0
        
        jj = jj+1;
        ll = ll+1; % increment aggregate counter
        particle_count = particle_count+1;
        
        Data = struct;
        
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
            [img_binary,~,Thresh_slider_in,img_cropped] = ...
                thresholding_ui.Agg_det_Slider(imgs(ii).Cropped,1);
            img_binary = ~img_binary;
            
            [~, img_edge,~] = manual.Thresh_refine(img_binary,...
                Thresh_slider_in);
            
            
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
            if ~exist('img_cropped','var')
                uiwait(msgbox('Please crop the image for primary particle sizing.'))
                img_cropped = imcrop(imgs(ii).Cropped);
                close (gcf);
            end
            
            img_cropped_primary = img_cropped;
            imshow(img_cropped_primary)
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
        
        while agg_primary == 1 && continuing_parameter ~= 3
            
            m = m+1;
            n_primary = m;
            
            uiwait(msgbox(['Please select two points on the image that correspond to the length of the ' title_measurement ],...
            ['Process Stage: Length of' title_measurement ' ' num2str(m)...
            '/' num2str(n_primary)],'help'));
            
             [x, y] = ginput(2);

             Data.length(m,1) = pixsize*sqrt((x(2)-x(1))^2+(y(2) - y(1))^2);
             line ([x(1),x(2)],[y(1),y(2)], 'linewidth', 3);

             [a, b] = ginput(2);

             Data.width(m,1) = pixsize*sqrt((a(2)-a(1))^2+(b(2) - b(1))^2);
             line ([a(1),a(2)],[b(1),b(2)],'Color', 'r', 'linewidth', 3);
             
             %-- Save center of primary particle -------------------------%
             Data.centers(m,:) = manual.find_centers(x,y,a,b);
             Data.radii(m,:) = (sqrt((a(2)-a(1))^2+(b(2)-b(1))^2)+...
                 sqrt((x(2)-x(1))^2+(y(2)-y(1))^2))/2;
             
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
        saveas(gcf,['data/ManualOutput/',imgs(ii).fname '_Primary_L_W_' num2str(jj) '.tif'])
        
        %== Step 3-5-4: Computing aggregate dimentions/parameters ========%
        if Particle_Type == 1
           
            area_pixelcount = nnz(img_binary); % number of non-zero pixels
            Data.area = nnz(img_binary)*pixsize^2; % aggregate area
            
            Data.perimeter = manual.Perimeter_Length(img_binary,pixsize,area_pixelcount);
                % calculate aggregat perimeter
            
            %-- Calculating aggregate length and width -------------------%
            %   To determine the length and width of the agglomerate
            [Data.A_length, Data.A_width] = ...
                manual.Agg_Dimension(img_edge,pixsize);
                % calculate aggregate length and width
            
            [Data.Rg] = manual.Gyration(img_binary, pixsize);
                % calculate radius of gyration
            
        end
        
        
        %== Save results =============================================%
        %   Format output and autobackup data ------------------------%
        Data.img_cropped = img_cropped;
        
        Agg(ll).fname = imgs(ii).fname; % store file name with data
        Agg(ll).manual = Data; % copy Dp data structure into img_data
        save('Data\manual_data.mat','Agg'); % backup img_data
            
        
        %-- Prepare output -----------------------------------------------%
        tot_primary=tot_primary+1;
        
        clear length width img_cropped % clear variables prior to next iteration
        
        close all;
        
        choice = questdlg('Do you want to analyse another aggregate ?',...
            'Continue?','Yes','No','Yes');
        if strcmp(choice,'Yes')
            continuing_aggregate = 1;     
        else
            continuing_aggregate = 0;
        end
        
        
    end

end



end

