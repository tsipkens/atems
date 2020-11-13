
% SEG_CNN_PT2  A simple function that reads binary images from a data folder.
% This is then used by the CarbonBlackSegmentation code before proceeding with 
% seg_cnn_pt2.
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

        %== Rolling Ball Transformation ==============================%
    if ~isempty(pixsize)  % if pixel size given, apply rolling ball transform
        morph_param = 0.8/pixsize(ii); % parameter used to adjust morphological operations

        ds = round(4 * morph_param);
        se6 = strel('disk', max(ds, 1));
            % disk size limited by size of holes in particle
        i7 = imclose(img_binary{ii}, se6);

        se7 = strel('disk', max(ds-1, 0));
            % disk size must be less than se6 to maintain connectivity
        img_rb = imopen(i7, se7);

        img_binary{ii} = bwareaopen(img_rb, 50); % remove particles below 50 pixels
    end    
end


end

