
% GET_FOOTER_SCALE Crops the footer from the image and determines the scale.
%=========================================================================%

function [img,pixsize] = get_footer_scale(img)

for jj=1:length(img)

    %-- Step 1-3: Crop footer away ---------------------------------------%
    % when the program reaches a row of only white pixels, removes
    % everything below it (specific to ubc photos). It will do nothing if
    % there is no footer or the footer is not pure white.
    footer_found = 0;
    WHITE = 255;

    for ii = 1:size(img(jj).RawImage,1)
        if sum(img(jj).RawImage(ii,:)) == size(img(jj).RawImage,2)*WHITE && ...
                footer_found == 0
            FooterEdge = ii;
            footer_found = 1;
            img(jj).Cropped = img(jj).RawImage(1:FooterEdge-1, :);
            img(jj).Footer  = img(jj).RawImage(FooterEdge:end, :);

            break;
        end
    end

    if footer_found == 0
        img(jj).Cropped = img(jj).RawImage;
    end


    %-- Step 1-2: Detecting Magnification and/or pixel size --------------%
    img(jj).ocr = ocr(img(jj).Footer);
    bool_nm = 1;

    pixsize_end = strfind(img(jj).ocr.Text,' nm/pix')-1;
    if isempty(pixsize_end) % if not found, try nmlpix
        pixsize_end = strfind(img(jj).ocr.Text,' nmlpix')-1;
        if isempty(pixsize_end)
            pixsize_end = strfind(img(jj).ocr.Text,' pm/pix')-1;
            if isempty(pixsize_end)
                pixsize_end = strfind(img(jj).ocr.Text,' pmlpix')-1;
            end
            bool_nm = 0;
        end
    end

    pixsize_start = strfind(img(jj).ocr.Text,'Cal')+5;
    img(jj).pixsize = str2double(img(jj).ocr.Text(pixsize_start:pixsize_end));
    if bool_nm==0; img(jj).pixsize = img(jj).pixsize*1e3; end
    
    %{
    %-- Step1-2: Detecting Magnification and/or pixel size ---------------%
    % Determining image magnification. Image magnification can be detected
    % automatically if images are taken at UBC. In this case, image footer
    % is scanned for the defalut text and numbers used by our Quartz PCI
    % software by which TEM images are captured. Users can develop similar
    % scripts for their own images.
    % If images are not taken at UBC, and they all are taken at the same
    % magnification, this part can be modified to prevent
    % inserting/detecting magnification/pixel size for each image; and use
    % and constant value for all images.
    pixsize_choise = questdlg('Determine pixel size','Image source',...
        'Use scale bar',...
        'Insert pixel size manually',...
        'UBC -> Automatic detection');

    if strcmp(pixsize_choise,'Use scale bar')
        % manually choosing the magnification
        uiwait(msgbox('Please crop the image close enough to the magnification bar'))
        img.mag_crop = imcrop(img.RawImage); % crop image
        close (gcf);
        imshow(img.mag_crop); % Show Cropped image
        set(gcf,'Position',get(0,'Screensize')); % Maximize figure.
        hold on
        uiwait(msgbox('Click on a point at the start (left) of the scale bar, then on a point at the end (right) of the scale bar'));
        % user chooses two point on the edge of magnification bar
        clear bar.x bar.y
        [bar.x,bar.y] = ginput(2);
        % calculate number of pixels of magnification bar
        bar.l = abs(bar.x(2)-bar.x(1));
        line([bar.x(1),bar.x(2)],[bar.y(1),bar.y(1)],'linewidth', 3);
        dlg_title = 'Length of the magnification bar';
        promt1 = {'Please insert the length of the magnification bar in nm:'};
        num_lines = 1;
        default_l = {'100'}; %default value for user input
        % user input execution
        bar.size = str2double(cell2mat(inputdlg(promt1,dlg_title,num_lines,default_l)));
        clear num_lines dlg_title promt1 default_l
        pixsize = bar.size/bar.l;
        hold off
        close all
    elseif strcmp(pixsize_choise,'Insert pixel size manually')
        close (gcf);
        img.mag_crop = imcrop(img.RawImage); %crop image
        close (gcf);
        imshow(img.mag_crop); % Show Cropped image
        set(gcf,'Position',get(0,'Screensize')); % Maximize figure.
        dlg_title = 'Pixel size';
        promt1 = {'Please insert the pixel size in nm/pixel:'};
        num_lines = 1;
        default_l = {'0.535592'}; %default value for user input
        % user input execution
        pixsize = str2double(cell2mat(inputdlg(promt1,dlg_title,num_lines,default_l)));
    end
    %}

end

pixsize = [img(1).pixsize];

end



