
% SEG_CNN_PT1  A simple function that saves cropped images to a data folder.
% This is then used by the CarbonBlackSegmentation code before proceeding with 
% seg_cnn_pt2.
%=========================================================================%

function [fd] = seg_cnn_pt1(imgs, fnames, fd)

%-- Get file names and parse inputs --------------------------------------%
if isstruct(imgs) % convert input images to a cell array
    Imgs = imgs;
    imgs = {Imgs.cropped};
    fnames = {Imgs.fname};
end

if ~iscell(imgs); imgs = {imgs}; end
if ~iscell(fnames); fnames = {fnames}; end

if ~exist('fd', 'var'); fd = []; end
if isempty(fd) % Browse to get path for CarbonBlackSegmentation code
    uiwait(msgbox( ...
        'Select upper directory of CarbonBlackSegmentation code.'));
    [fd] = uigetdir('', ...
        'Select directory');
end
%-------------------------------------------------------------------------%

% Look for deployment folder to determine if appropriate directory
if ~exist([fd, '\deployment'], 'dir')
    error('Invalid CarbonBlackSegmentation directory.');
end

% Write images to data folder
tools.write_images(imgs, fnames, [fd, '\data'])

end

