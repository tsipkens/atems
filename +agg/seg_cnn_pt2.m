
% SEG_CNN_PT2  A simple function that reads binary images from a data folder.
% This is then used by the CarbonBlackSegmentation code before proceeding with 
% seg_cnn_pt2.
%=========================================================================%

function [img_binary] = seg_cnn_pt2(fnames, fd)

%-- Get file names and parse inputs --------------------------------------%
if isstruct(fnames) % convert input images to a cell array
    fnames = {fnames.fname};
end
if ~iscell(fnames); fnames = {fnames}; end

if ~exist('fd', 'var'); fd = []; end
if isempty(fd)
    uiwait(msgbox( ...
        'Select upper directory of CarbonBlackSegmentation code.'));
    fd = uigetdir('', ...
        'Select directory'); % browse to get CarbonBlackSegmentation directory
    
    % Look for deployment folder to determine if appropriate directory
    if ~exist([fd, '\deployment'], 'dir')
        error('Invalid CarbonBlackSegmentation directory.');
    end
end
%-------------------------------------------------------------------------%

img_binary = {};
for ii=length(fnames):-1:1
    img_binary{ii} = imread([fd, '\results\', fnames{ii}]);
    img_binary{ii} = img_binary{ii}(:,:,1)~=0;
end

end

