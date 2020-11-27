
% SEG_EXT  A simple function that saves cropped images for external segmentation.
% This can then be used by external segmenters: 
%   - The CarbonBlackSegmentation code before proceeding with seg_cnn_pt2.
%   - Fiji in conjuction with trainable Weka segmentation.
%=========================================================================%

function [fd] = seg_ext(imgs, fnames, fd)

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
        ['Select upper directory of external code. ', ...
        'Images will be placed in <strong>data</strong> folder.'));
    [fd] = uigetdir('', ...
        'Select directory');
end
%-------------------------------------------------------------------------%


% Write images to data folder
tools.write_images(imgs, fnames, [fd, '\data'])

end

