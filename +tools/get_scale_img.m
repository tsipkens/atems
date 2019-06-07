
function [img,pixsize] = get_scale_img(img)

%% Step 1-3: Crop footer away
% when the program reaches a row of only white pixels, removes
% everything below it (specific to ubc photos). It will do nothing if
% there is no footer or the footer is not pure white.
footer_found = 0;
for i = 1:size(img.RawImage,1)
    if sum(img.RawImage(i,:)) == size(img.RawImage,2)*255 && ...
            footer_found == 0

        FooterEdge   = i;
        footer_found = 1;
        img.Cropped  = img.RawImage(1:FooterEdge-1, :);
        img.Footer  = img.RawImage(FooterEdge:end, :);

    end
end

if footer_found == 0
    img.Cropped = img.RawImage;
end


%% Step 1-2: Detecting Magnification and/or pixel size
img.ocr = ocr(img.Footer);
pixsize_end = strfind(img.ocr.Text,' nm/pix')-1;
if isempty(pixsize_end) % if not found, try nmlpix
    pixsize_end = strfind(img.ocr.Text,' nmlpix')-1;
end
pixsize_start = strfind(img.ocr.Text,'Cal')+5;
pixsize = str2double(img.ocr.Text(pixsize_start:pixsize_end));

disp(['Pixel size: ',num2str(pixsize),' nm/pixel']);

%{
%% Step1-2: Detecting Magnification and/or pixel size
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



