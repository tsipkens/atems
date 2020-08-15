
% GET_IMGS_REF Loads references to image files, including their name and directory.
% Expects data to be located at '../data', that is in a folder named 'data'
% up a single directory. 
% Author: Timothy Sipkens
%=========================================================================%

function Imgs = get_imgs_ref()

flag = 0; % 0: no image loaded; 1: at least one image loaded
% loop continues until at least image is selected or the program is stopped

Imgs.fname = ''; % initialize image reference structure
Imgs.dir = '';

%-- Get file information -------------------------------------------------%
while flag == 0
    dir_start = '..\data'; % initial directory to look for images
    
    [fname, dir] = uigetfile({'*.tif;*.jpg',...
        'TEM image (*.tif;*.jpg)'},'Select Images',dir_start,'MultiSelect',...
        'on'); % user browses for images, modifying for other image formats
    
    if iscell(fname) % Handling when only one image is selected
        flag = 1;
        for ii=length(fname):-1:1
            Imgs(ii).fname = fname{ii};
            Imgs(ii).dir = dir;
        end
    elseif Imgs.fname==0
        error('No image selected.');
    else
        Imgs.fname = fname;
        Imgs.dir = dir;
        flag = 1;
    end
end
%-------------------------------------------------------------------------%


end

