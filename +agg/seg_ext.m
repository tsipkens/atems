
% SEG_EXT  A simple function that saves cropped images for external segmentation.
%  This can then be used by external segmenters: 
%   + The carboseg code before proceeding with seg_cnn_pt2.
%   + Fiji in conjuction with trainable Weka segmentation.
%=========================================================================%

function [fnames] = seg_ext(imgs, fnames, fd, ext)

%-- Get file names and parse inputs --------------------------------------%
if isstruct(imgs) % convert input images to a cell array
    Imgs = imgs;
    imgs = {Imgs.cropped};
    fnames = {Imgs.fname};
end

if ~iscell(imgs); imgs = {imgs}; end
if ~iscell(fnames); fnames = {fnames}; end

if ~exist('ext', 'var'); ext = []; end  % if file extension not specified

if ~exist('fd', 'var'); fd = []; end
if isempty(fd) % Browse to get path for CarbonBlackSegmentation code
    uiwait(msgbox( ...
        ['Select folder to which to save images.']));
    fd = uigetdir('', 'Select directory');
end
%-------------------------------------------------------------------------%


% Write images to data folder
disp('Saving images ...');
fnames = tools.write_images(imgs, fnames, fd, ext);
tools.textdone(2);  % print orange DONE


if nargout==0; clear fnames; end  % clear output if not required

end

