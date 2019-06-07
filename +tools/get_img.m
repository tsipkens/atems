function img = get_img()
% GET_IMG Loads images; getting image file name and directory

img.num = 0; % 0: no image loaded; 1: at least one image loaded
% loop continues until at least image is selected or the program is stopped

while img.num == 0
    dir_start = '..\Images'; % initial directory to look for images
    
    message = sprintf('Please choose image(s) to be analyzed...');
    
    [img.files,img.dir] = uigetfile({'*.tif;*.jpg',...
        'TEM image (*.tif;*.jpg)'},'Select Images',dir_start,'MultiSelect',...
        'on');% User browses for images. Modify for other image formats
    img.num = size(img.num,2);
    
    if iscell(img.files) % Handling when only one image is selected
        img.files = img.files';
    elseif img.files==0
        pixsize_choice=questdlg('No image was selected! Do you want to try again?', ...
            'Error','Yes','No. Quit debugging','Yes');
        
        if strcmp(pixsize_choice,'No. Quit debugging')
            uiwait(msgbox('No image was selected and user decided to stop the program'))
            error('No image was selected and user decided to stop the program');
        else
            img.num= 0;
        end
    end
end
[img.num,~] = size(img.files); % Total number of images loaded



end

