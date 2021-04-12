
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

function [img_binary] = seg_cnn_pt2(fnames, fd, pixsizes)

%-- Get file names and parse inputs --------------------------------------%
if isstruct(fnames) % convert input images to a cell array
    fnames = {fnames.fname};
end
if ~iscell(fnames); fnames = {fnames}; end

if ~exist('fd', 'var'); fd = []; end
if isempty(fd)
    uiwait(msgbox( ...
        'Select the output (from Python) image folder.'));
    fd = uigetdir('', ...
        'Select directory'); % browse to get output image directory
end

if ~exist('pixsizes', 'var'); pixsizes = []; end
if and(~isempty(pixsizes), length(pixsizes)==1)
    pixsizes = pixsizes .* ones(size(fnames));  % extend pixel size if scalar
end
%-------------------------------------------------------------------------%

img_binary = {};
for ii=length(fnames):-1:1
    img_binary{ii} = imread([fd, filesep, fnames{ii}]);
    img_binary{ii} = img_binary{ii}(:,:,1)~=0;
    
    %-{
    %== Rolling Ball Transformation ==============================%
    if ~isempty(pixsizes)  % if pixel size given, apply rolling ball transform
        morph_param = 0.8/pixsizes(ii); % parameter used to adjust morphological operations

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

