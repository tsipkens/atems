
% GET_IMG_REF Loads references to image files, including their name and directory.
% Expects data to be located at '../data', that is in a folder named 'data'
% up a single directory. 
% Author: Timothy Sipkens
%=========================================================================%

function img = get_img_ref()

img.num = 0; % 0: no image loaded; 1: at least one image loaded
% loop continues until at least image is selected or the program is stopped

while img.num == 0
    dir_start = '..\data'; % initial directory to look for images
    
    [img.fname,img.dir] = uigetfile({'*.tif;*.jpg',...
        'TEM image (*.tif;*.jpg)'},'Select Images',dir_start,'MultiSelect',...
        'on');% User browses for images. Modify for other image formats
    img.num = size(img.num,2);
    
    if iscell(img.fname) % Handling when only one image is selected
        img.fname = img.fname';
    elseif img.fname==0
        error('No image selected.');
    else
        img.fname = {img.fname};
    end
end
[img.num,~] = size(img.fname); % Total number of images loaded


end

