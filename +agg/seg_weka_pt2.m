
% SEG_WEKA_PT2  A simple function that read binary images from a data folder.
% Expects segmentations produced by the trainable Weka segmentation from
% Fiji.
%
% Assumes that images are in the same alphabetical order in the WEKA results
% folder as in the fnames cell. 
%=========================================================================%

function [img_binary] = seg_weka_pt2(fnames, fd, f_reverse)

%-- Get file names and parse inputs --------------------------------------%
if isstruct(fnames) % convert input images to a cell array
    fnames = {fnames.fname};
end
if ~iscell(fnames); fnames = {fnames}; end

if ~exist('fd', 'var'); fd = []; end
if isempty(fd)
    uiwait(msgbox( ...
        'Select directory containing trainable Weka segmentation results.'));
    fd = uigetdir('', ...
        'Select directory'); % browse to get CarbonBlackSegmentation directory
end

% Flag indicatign whether to siwtch 0s and 1s, depending on how trainable
% Weka segmentation was set up. 
if ~exist('f_reverse', 'var'); f_reverse = []; end
if isempty(f_reverse); f_reverse = 0; end
%-------------------------------------------------------------------------%

img_binary = {};

fnames_weka = dir(fd);
fnames_weka(1:2) = [];

tools.textheader('Interpretting WEKA');
tools.textbar([0, length(fnames_weka)]);
for ii=length(fnames_weka):-1:1
    
    img_binary{ii} = imread([fd, filesep, fnames_weka(ii).name]);
    img_binary{ii} = img_binary{ii}(:,:,1)~=0;
    
    % Reverse binary mask, if necessary. 
    if f_reverse; img_binary{ii} = ~img_binary{ii}; end
    
    % Open binary mask with a disk with a 3 pixel size.
    se7 = strel('disk', 3);
    img_binary{ii} = imopen(img_binary{ii}, se7);
    
    % Remove particles below 1000 pixels.
    img_binary{ii} = bwareaopen(img_binary{ii}, 1e3);
    
    % Check number of particles, ignore image if
    % excessive number detected (sign of method failure). 
    CC = bwconncomp(img_binary{ii}); % find seperate aggregates
    naggs = CC.NumObjects; % count number of aggregates
    if naggs>50
        img_binary{ii} = 0 .* img_binary{ii};  % blank out to ignore
    end
    
    tools.textbar([length(fnames_weka) - ii + 1, ...
        length(fnames_weka)]);
end
tools.textheader();


end

