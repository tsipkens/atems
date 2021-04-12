
% SEG_CNN_PT2  A simple function that read binary images from a data folder.
%  Expects segmentations produced by the CarbonBlackSegmentation package:
%  See https://github.com/maxfrei750/CarbonBlackSegmentation. 
% 
%  NOTE:
%   A rolling ball transform is applied only and always when the pixsize
%   argument is given. 
%   In other words, if one does NOT want to apply the rolling ball
%   transform, do NOT give a pixsize. If one does want to apply the rolling
%   ball transform, one MUST supply pixsize. 
%=========================================================================%

function [img_binary] = seg_cnn_pt2(fnames, fd, pixsize)

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

if ~exist('pixsize', 'var'); pixsize = []; end
if and(~isempty(pixsize), length(pixsize)==1)
    pixsize = pixsize .* ones(size(fnames));  % extend pixel size if scalar
end
%-------------------------------------------------------------------------%

img_binary = {};
for ii=length(fnames):-1:1
    img_binary{ii} = imread([fd, '\results\', fnames{ii}]);
    img_binary{ii} = img_binary{ii}(:,:,1)~=0;
    
    %-{
    %== Rolling Ball Transformation ==============================%
    if ~isempty(pixsize)  % if pixel size given, apply rolling ball transform
        morph_param = 0.8/pixsize(ii); % parameter used to adjust morphological operations

        % Disk size limited by size of holes in particle.
        ds = round(4 * morph_param);
        se6 = strel('disk', max(ds, 1));
        i7 = imclose(img_binary{ii}, se6);
        
        % Disk size must be less than se6, 
        % to maintain connectivity.
        se7 = strel('disk', max(ds-1, 0));
        img_binary{ii} = imopen(i7, se7);
        
        % Remove particles below 1000 pixels.
        img_binary{ii} = bwareaopen(img_binary{ii}, 1e3);
    end
    %}
    
end


end

