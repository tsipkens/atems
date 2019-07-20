
% EVALUATE  Performs the pair correlation method (PCM) of aggregate characterization
% 
% Developed at the University of British Columbia by Ramin Dastanpour and
% Steven N. Rogak
%
% Image processing package for the analysis of TEM images. Automatic
% aggregate detection and automatic primary particle sizing
%
% This code was more recently modified by Timothy Sipkens at the University
% of British Columbia
%=========================================================================%

function [Agg,imgs] = evaluate(imgs,bool_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end

Agg = struct;


%-- Initialize values ----------------------------------------------------%
fontSize        = 10;
% minparticlesize = 4.9; % to filter out noises
% % Coefficient for automatic Hough transformation
% coeff_matrix    = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
%     0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
% moreaggs    = 0;


ll = 0; % initialize aggregate counter

%== Main image processing loop ===========================================%
for ii = 1:length(imgs) % run loop as many times as images selected
    
    %== Step 1: Image preparation ========================================%
    %-- Step 1-3: Crop footer and get scale from footer (now external) ------------------%
    pixsize = imgs(ii).pixsize;
    
%     % Build the image processing coefficients for the image based on its
%     % magnification
%     if pixsize <= 0.181
%         coeffs = coeff_matrix(1,:);
%     elseif pixsize <= 0.361
%         coeffs = coeff_matrix(2,:);
%     else 
%         coeffs = coeff_matrix(3,:);
%     end
    
    % Displaying the image
    imshow(imgs(ii).Cropped);
    title('processing Image', 'FontSize', fontSize);
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    
    %-- Step 1-4: Saving Cropped image -----------------------------------%
    close (gcf);
    
    % Check whether the Output folder is available 
    dirName = 'data\PCMOutput\';
    
    if exist(dirName,'dir') ~= 7 % 7 if exist parameter is a directory
        mkdir(dirName) % make output folder
    end
    
    
    %== Step 2: Automatic/semi-automatic aggregate detection =============%
%     imgs(ii).Binary = pcm.Agg_detection(imgs(ii),pixsize,moreaggs,minparticlesize,coeffs);
%     
%     imgs(ii).Edge   = edge(imgs(ii).Binary,'sobel'); % Sobel edge detection
%     SE              = strel('disk',1);
%     imgs(ii).DilatedEdge = imdilate(imgs(ii).Edge,SE); % morphological dilation
%     
%     clear img.Edge SE2
%     imgs(ii).Imposed = imimposemin(imgs(ii).Cropped, imgs(ii).DilatedEdge);
%     
%     [imgs(ii).Binary,imgs(ii).dilatedEdge,imgs(ii).Imposed] =  ... 
%         thresholding_ui.detectAggregate(imgs(ii));
%     
    %== Step 3: Automatic primary particle sizing ========================%
    %-- Step 3-1: Find and size all particles on the final binary image --%
    CC = bwconncomp(abs(imgs(ii).Binary-1));
    NofAggs = CC.NumObjects; % count number of particles
    
    %-- Lopp for each aggregate on the image under investigation ---------%
    for nAgg = 1:NofAggs
        
        ll = ll + 1; % increment aggregate counter
        
        Data = struct; % initialize data structure for current aggregate
        Data.method = 'pcm';
        
        
        %-- Step 3-2: Prepare an image of the isolated aggregate ---------%
        Data.Image = zeros(size(imgs(ii).Binary));
        Data.Image(CC.PixelIdxList{1,nAgg}) = 1;
        
        % Edge Image via Sobel
        % Use Sobel's Method as a built-in edge detection function for
        % aggregates's outline. Other methods (e.g. Roberts, Canny)can also
        % be considered
        Image_edge = edge(Data.Image,'sobel');
        
        % Dilated Edge Image
        % Use dilation to strengthen the aggregate's outline
        SE = strel('disk',1);
        img_dilated = imdilate(Image_edge,SE);
        clear Image_edge SE
        img_final_imposed = imimposemin(imgs(ii).Cropped, img_dilated);
        figure
        hold on
        imshow(img_final_imposed);
        
        %-- Step 3-3: Development of the pair correlation function (PCF) -%
        
        %-- 3-3-1: Find the skeleton of the aggregate --------------------%
        Skel = bwmorph(Data.Image,'thin',Inf);
        [skeletonY, skeletonX] = find(Skel);
        
        %-- 3-3-2: Calculate the distances between skeleton pixels and other pixels
        clear row col
        [row, col] = find (Data.Image);
        
        
        Data.Pixels = nnz(Data.Image); % total number of pixels in aggregate
        
        % to consolidate the pixels of consideration to much smaller arrays
        
        p       = 0;
        X       = 0;
        Y       = 0;
        density = 20; % larger densities make the program less computationally expensive
        
        for kk = 1:density:Data.Pixels
            p    = p + 1;
            X(p) = col(kk);
            Y(p) = row(kk);
        end
        
        % to calculate all the distances with reference to one pixel at a time,
        % using vector algebra, and then adding the results
        for kk = 1:1:length(skeletonX)
            Distance_int = ((X-skeletonX(kk)).^2+(Y-skeletonY(kk)).^2).^.5;
            Distance_mat(((kk-1)*length(X)+1):(kk*length(X))) = Distance_int;
        end
        
        %-- 3-3-3: Construct the pair correlation ------------------------%
        %   Sort radii into bins and calculate PCF
        Distance_max = double(uint16(max(Distance_mat)));
        Distance_mat = nonzeros(Distance_mat).*pixsize;
        nbins        = Distance_max * pixsize;
        dr           = 1;
        Radius       = 1:dr:nbins;
        
        % Pair correlation function (PCF)
        PCF = hist(Distance_mat, Radius);
        
        % Smoothing the pair correlation function (PCF)
        d                                  = 5 + 2*Distance_max;
        BW1                                = zeros(d,d);
        BW1(Distance_max+3,Distance_max+3) = 1;
        BW2                                = bwdist(BW1,'euclidean');
        BW4                                = BW2./Distance_max;
        BW5                                = im2bw(BW4,1);
        
        clear row col
        
        [row,col]            = find(~BW5);
        Distance_Denaminator = ((row-Distance_max+3).^2+(col-Distance_max+3).^2).^.5;
        Distance_Denaminator = nonzeros(Distance_Denaminator).*pixsize;
        Denamonator          = hist(Distance_Denaminator,Radius);
        Denamonator          = Denamonator.*length(skeletonX)./density;
        PCF                  = PCF./Denamonator;
        PCF_smoothed         = smooth(PCF);
        
        for kk=1:size(PCF_smoothed)-1
            if PCF_smoothed(kk) == PCF_smoothed(kk+1)
                PCF_smoothed(kk+1) = PCF_smoothed(kk)-1e-4;
            end
        end
        
        %-- 3-4: Computing aggregate dimentions/parameters ---------------%
        % Projected area of the aggregate
        Data.area = Data.Pixels*pixsize^2;
        
        % Projected area equivalent diameter of the aggregate
        Data.da = ((Data.Pixels/pi)^.5)*2*pixsize;
        
        % Aggregate Perimeter
        clear row col
        [row, col]           = find(Data.Image);
        perimeter_pixelcount = 0;
        
        for kk = 1:1:Data.Pixels
            if  (Data.Image(row(kk)-1,col(kk))==0) || ...
                (Data.Image(row(kk),col(kk)+1)==0) || ...
                (Data.Image(row(kk),col(kk)-1)==0) || ...
                (Data.Image(row(kk)+1,col(kk))==0)
                
                perimeter_pixelcount = perimeter_pixelcount + 1;
            end
        end
        
        Data.perimeter = perimeter_pixelcount*pixsize;
        
        % Aggregate gyration radius
        % NOTE: Consider moving to aggregate detection code
        [xpos,ypos] = find(Data.Image);
        n_pix       = length(xpos);
        centroid.x  = sum(xpos)/n_pix;
        centroid.y  = sum(ypos)/n_pix;
        Ar          = zeros(n_pix,1);
        
        for kk = 1:n_pix
            Ar(kk,1) = (((xpos(kk,1)-centroid.x)*pixsize)^2+...
                      ((ypos(kk,1)-centroid.y)*pixsize)^2)*pixsize^2;
        end
        
        Data.Rg = (sum(Ar)/Data.area)^0.5;
        clear Ar ypos xpos Centroid.x Centroid.y
        
        % Aggregate Length, Width, and aspect ratio      
        Data.L           = max((max(row)-min(row)),(max(col)-min(col)))*pixsize;
        Data.W           = min((max(row)-min(row)),(max(col)-min(col)))*pixsize;
        Data.aspect_ratio = Data.L/Data.W;
        
        %-- 3-5: Primary particle sizing ---------------------------------%
        %-- 3-5-1: Simple PCM --------------------------------------------%
        PCF_simple   = .913;
        Data.RpSimple = interp1(PCF_smoothed, Radius, PCF_simple);
        
        %-- 3-5-2: Generalized PCM ---------------------------------------%
        URg      = 1.1*Data.Rg; % 10% higher than Rg
        LRg      = 0.9*Data.Rg; % 10% lower than Rg
        PCFRg    = interp1(Radius, PCF_smoothed, Data.Rg); % P at Rg
        PCFURg   = interp1(Radius, PCF_smoothed, URg); % P at URg
        PCFLRg   = interp1(Radius, PCF_smoothed, LRg); % P at LRg
        PRgslope = (PCFURg+PCFLRg-PCFRg)/(URg-LRg); % dp/dr(Rg)
        
        PCF_generalized   = (.913/.84)*(0.7+0.003*PRgslope^(-0.24)+0.2*Data.aspect_ratio^-1.13);
        Data.RpGeneralized = interp1(PCF_smoothed, Radius, PCF_generalized);
        
        %-- Plot pair correlation function in line graph format ----------%
        filename = 'Pair Correlation Function Plot.jpeg';
        path     = sprintf('PCF_%d_%d_new',nAgg,ii);
        str      = sprintf('Pair Correlation Line Plot %f ',PCF_simple);
        
        figure, loglog(Radius, smooth(PCF), '-r'), title (str), xlabel ('Radius'), ylabel('PCF(r)')
        
        hold on
        
        loglog(Data.RpSimple,PCF_simple,'*')
        close all
        
        %-- Clear variables ----------------------------------------------%
        clear Agg.Image Image_edge FinalImposedImage Skel skeletonY ...
            skeletonX Agg.Pixels Distance_mat Radius PCF PCF_smoothed ...
            Denamonator row col
        
        %== Step 4: Save results =========================================%
        %   Format output and autobackup data ----------------------------%
        Agg(ll).fname = imgs(ii).fname; % store file name with data
        Agg(ll).pcm = Data; % copy Dp data structure into img_data
        save('data\pcm_data.mat','Agg'); % backup img_data
        
        
        %== Step 4: Save results =========================================%
        %{
        
        %   Global mainfolder img img.dir FileName
        extracted_text = cell(1,1);


        %-- Report title ---------------------------------------------------------%
        report_title = {'Image_ID','Particle Area (nm^2)','Particle Perimeter (nm)',...
            'Particle Length (nm)','Particle Width (nm)','Particle aspect ratio',...
            'Radius of Gyration (nm)','Particle eq. da (nm)',...
            'dp (nm) [simple PCF]','dp (nm) [generalized PCF]','Max resolution (nm)','Engine Type'};


        %-- Choose appropriate value for based on your Excel version -------------%
        xls_sheet = 2; % Uncomment this if your default MS Excel version is 2013
        % xls_sheet = 4; % Uncomment this if your default MS Excel version is <2013
        
        extracted_data(1) = round(agg.Area,2);
        extracted_data(2) = round(agg.Perimeter,2);
        extracted_data(3) = round(agg.L,2);
        extracted_data(4) = round(agg.W,2);
        extracted_data(5) = round(agg.Aspectratio,2);
        extracted_data(6) = round(agg.Rg,2);
        extracted_data(7) = round(agg.da,2);
        extracted_data(8) = round(2*agg.RpSimple,2); % dp from simple PCM
        extracted_data(9) = round(2*agg.RpGeneralized,2); % dp from generalized PCM
        extracted_data(10) = round(pixsize,3);
        extracted_text(1)={fname};
        %}
        
        %{
        %-- Step 4-1: Autobackup -----------------------------------------%
        if exist('Data\PCMOutput\PCM_data.mat','file')==2
            save('Data\PCMOutput\PCM_data.mat','extracted_data','extracted_text','-append');
        else
            save('Data\PCMOutput\PCM_data.mat','extracted_data','extracted_text','report_title');
        end
        
        if exist('Data\PCMOutput\PCM_Output.xls','file')==2
            [~,sheets,~] = xlsfinfo('Data\PCMOutput\PCM_Output.xls'); %finding info about the excel file
            sheetname=char(sheets(1,xls_sheet)); % choosing the second sheet
            [datanum]=xlsread('Data\PCMOutput\PCM_Output.xls',sheetname); %loading the data
            starting_row=size(datanum,1)+2;
            xlswrite('Data\PCMOutput\PCM_Output.xls',extracted_text,'TEM_Results',['A' num2str(starting_row)]);
            xlswrite('Data\PCMOutput\PCM_Output.xls',extracted_data,'TEM_Results',['B' num2str(starting_row)]);
        else
            savecounter = 1;
            xlswrite('Data\PCMOutput\PCM_Output.xls',report_title,'TEM_Results','A1');
            xlswrite('Data\PCMOutput\PCM_Output.xls',extracted_text,'TEM_Results','A2');
            xlswrite('Data\PCMOutput\PCM_Output.xls',extracted_data,'TEM_Results','B2');
        end
        %}
        
    end
    
    
end
