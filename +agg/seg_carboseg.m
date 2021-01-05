
% SEG_CARBOSEG  A segmenter, relying on the Python implementation of a CNN.
% Requires the carboseg or equivalent Python environment. Initialize the
% Python environment before calling this function (cf., tools.load_python).
% AUTHOR: Timothy Sipkens, 2021-01-05
%=========================================================================%

function [img_binary] = seg_carboseg(imgs, pixsizes)


%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs) % convert input images to a cell array
    Imgs = imgs;
    imgs = {Imgs.cropped};
    pixsizes = [Imgs.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

n = length(imgs); % number of images to consider

if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = ones(size(imgs)); end
if length(pixsizes)==1; pixsizes = pixsizes .* ones(size(imgs)); end % extend if scalar
%-------------------------------------------------------------------------%


tools.textheader('CNN (carboseg)');

disp('Importing CNN classifier in Python...');
disp(' ');
py.importlib.import_module('segmenter');

seg = py.segmenter.Segmenter;  % create instance of segmenter
disp(seg);
disp(' ');

img_binary = {};
disp('Running CNN classifier in Python:');
tools.textbar([0, length(imgs)]);
for ii=1:length(imgs)
    img_py = py.numpy.array(cat(3, imgs{ii}, imgs{ii}, imgs{ii}));  % format input
    
    img_binary0 = seg.segment_image(img_py);  % apply classifier
    
    img_binary{ii} = double(img_binary0);  % format output
    
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
    
    tools.textbar([ii, length(imgs)]);  % update textbar
end

tools.textheader();



end
