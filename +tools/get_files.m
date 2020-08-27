
% GET_FILES  Loads references to image files, including their name and directory.
% Expects data to be located at '../data', that is in a folder named 'data'
% up a single directory. 
% Author: Timothy Sipkens
%=========================================================================%

function Imgs = get_files(fd)

if ~exist('fd','var'); fd = []; end

flag = 0; % 0: no image loaded; 1: at least one image loaded
% loop continues until at least image is selected or the program is stopped

Imgs.fname = ''; % initialize image reference structure


%-- Get file information -------------------------------------------------%
while flag == 0
    dir_start = 'images'; % initial directory to look for images
    
    % Browse or get file information.
    if isempty(fd) % if no folder, user browses for images (tif,jpg)
        [fname, folder] = uigetfile({'*.tif;*.jpg', 'TEM image (*.tif;*.jpg)'}, ...
            'Select Images', dir_start, 'MultiSelect', 'on');
    else % if folder is given, get all tif files in the folder
        t0 = dir(fullfile(fd,'*.tif')); % pattern to match filenames
        fname = {t0.name};
        folder = t0(1).folder;
    end
    
    % Format file information for output
    if iscell(fname) % handle a cell array of files
        flag = 1;
        for ii=length(fname):-1:1
            Imgs(ii).fname = fname{ii};
            Imgs(ii).folder = folder;
        end
    elseif Imgs.fname==0 % handle when no image was selected
        error('No image selected.');
    else % handle when only one image is selected
        Imgs.fname = fname;
        Imgs.folder = folder;
        flag = 1;
    end
end
%-------------------------------------------------------------------------%


end

