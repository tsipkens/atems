function [Binary_image] = Agg_detection(img,pixsize,moreaggs,minparticlesize,coeffs) 
% Automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% 

%% Hough transformation
[Binary_image,moreaggs,choice] = pcm.Agg_det_Hough(img.Cropped,pixsize,moreaggs,minparticlesize,coeffs);

%% Showing detected particles
% Make masked image so that user can see if particles have been erased or not
if size(Binary_image,1)~=0
    Edge_Image = edge(Binary_image,'sobel');
    SE = strel('disk',1);
    Dilated_Edge_Image = imdilate(Edge_Image,SE);
    clear Edge_Image SE
    FinalImposedImage = imimposemin(img.Cropped, Dilated_Edge_Image);
    figure; imshow(FinalImposedImage);
end

%% User interaction
if strcmp(choice,'Yes') || strcmp(choice,'Yes, but reduce noise')
    clear choice
    choice = questdlg('Are there any particles not detected?',...
        'Missing particles',...
        'Yes','No','No');
    if strcmp(choice,'Yes')
        moreaggs=1;
    end
else
    moreaggs=1;
end

%% Finding missing aggregates
while moreaggs==1
    clear choice
    uiwait(msgbox('Please crop the image around missing particle'));
    [Cropped_img, rect] = imcrop(img.Cropped); % user crops the image
    [Final_Binary_int,~,choice] = ...
        pcm.Agg_det_Hough(Cropped_img,pixsize,moreaggs,minparticlesize,coeffs);

   if strcmp(choice,'No')
        %clear rect
        if size(Binary_image,2) == 0
            Binary_image = zeros(size(img.Cropped,1),size(img.Cropped,2))+1;
        end
        %% Semi-Automatic selection
        % User draws a freehand (similar to lasso tool in Adope Photoshop)
        % boundary around the missing particle. Background correction and
        % image refinments will be only applied to the interior of this
        % object.
        [NewBW_lasoo,rect] = thresholding_ui.Agg_det_Slider(img.Cropped);
        % Intermediate images are stored in temporary matrices
        TempBW = Binary_image;
        %the black part of the small cropped image is placed on the image
        TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1)) = ...
        NewBW_lasoo(1:round(rect(4))-1,1:round(rect(3))-1).* TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1));
        imshow(TempBW);
        NewBW = TempBW;
        
        Edge_Image = edge(NewBW,'sobel');
        SE = strel('disk',1);
        Dilated_Edge_Image = imdilate(Edge_Image,SE);
        clear Edge_Image SE2
        FinalImposedImage = imimposemin(img.Cropped, Dilated_Edge_Image);
        figure; imshow(FinalImposedImage);
        
        %% Semi-automatic detection
        choice2 = questdlg('Satisfied with aggregate detection? If not, try drawing an edge around the aggregate manually...',...
            'Agg detection','Yes','No','Yes');
        if strcmp(choice2,'No')
            clear TempBW NewBW_lasoo NewBW
            [NewBW_lasoo,rect] = Agg_det_Slider(img.Cropped);
            %image is stored in a temporary image
            TempBW = Binary_image;
            %the black part of the small cropped image is placed on the image
            TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1)) = ...
            NewBW_lasoo(1:round(rect(4))-1,1:round(rect(3))-1).* TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1));
            imshow(TempBW);
            NewBW = TempBW;
        end
        clear TempBW NewBW_lasoo
                
    else
        if size(Binary_image,2)==0
            Binary_image=zeros(size(img.Cropped,1),size(img.Cropped,2))+1;
        end
        TempBW = Binary_image;
        % the black part of the small cropped image is masked on the image
        TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1)) = ...
        Final_Binary_int(1:round(rect(4))-1,1:round(rect(3))-1).* TempBW(round(rect(2)):round(rect(2)+rect(4))-1,round(rect(1)):round(rect(1)+rect(3)-1));
        NewBW = TempBW; % if successful, save it
    end

    Binary_image = NewBW;
    imshow(NewBW)
    clear TempBW rect Cropped_img NewBW choice Final_Binary
    
    Edge_Image = edge(Binary_image,'sobel');
    SE = strel('disk',1);
    Dilated_Edge_Image = imdilate(Edge_Image,SE);
    clear Edge_Image0 SE2
    FinalImposedImage = imimposemin(img.Cropped, Dilated_Edge_Image);
    figure; imshow(FinalImposedImage);
    
    choice = questdlg('Are there any particles not detected?',...
        'Missing particles','Yes','No','No');
    if strcmp(choice,'Yes')
        moreaggs=1;
    else
        moreaggs=0;
    end
end
