
% SEG  Sequential attempts at semi-automatic detection of the aggregates on TEM images.
%           Attempts k-means + rolling ball, Otsu + rolling ball, slider
%           thresholding. Acts as a wrapper function for implementing 
%           several other seg*.m methods
% AUTHOR: Ramin Dastanpour, Steven N. Rogak
%         Developed at the University of British Columbia
% MODIFIED: Timothy Sipkens, 2019
%=========================================================================%


%== WRAPPER FUNCTION ====================================================%
%   Used to loop over multiple images. 
function [imgs_binary] = seg(imgs,pixsize,opts)

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs_str = imgs;
    imgs = {Imgs_str.cropped};
    pixsize = [Imgs_str.pixsize];
elseif ~iscell(imgs)
    imgs = {imgs};
end

n = length(imgs);

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

%-- Partially parse name-value pairs --%
if ~exist('opts','var'); opts = []; end
%-------------------------------------------------------------------------%


imgs_binary = cell(length(imgs),1); % pre-allocate
for ii=1:n % loop through provided images
    
    % Add header for this image.
    disp('{========================================}');
    tools.textheader(['Image ', num2str(ii), ' of ', num2str(length(imgs))]);
    
    %-- Run slider to obtain binary image --------------------------------%
    [img_binary,~,~,~] = seg_sub(imgs{ii}, pixsize(ii), ...
        [], [], opts); % includes removing aggregates from border
    
    if iscell(img_binary); img_binary = img_binary{1}; end
    imgs_binary{ii} = img_binary;
    
    % Write binaries to temporary file (in case an error occurs).
    if ~exist('temp', 'dir')
       mkdir('temp')
    end
    imwrite(imgs_binary{ii}, ['temp/segg_',num2str(ii),'.TIF']);
    
end

close(gcf); % close image with overlaid da
delete('temp/segg_*.TIF');

if n==1
    imgs_binary = imgs_binary{1}; % if one image, extract from cell
end


end





%== SEG_SUB ==============================================================%
%   Sub-function that segments a single image by attempting multiple methods. 
%   Author:  Timothy Sipkens, 10-10-2019
function [img_binary,img_cropped,agg_binary_bin,agg_cropped_bin] = ...
    seg_sub(img,pixsize,minparticlesize,coeffs,opts) 

agg_binary_bin = {};    % Bin of binary aggregate images
agg_cropped_bin = {};   % Bin of cropped aggregated images


%== Parse inputs =========================================================%
if ~exist('pixsize','var'); pixsize = []; end
if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

f_kmeans = 1;
f_otsu = 1;
if ~exist('opts','var'); opts = []; end
if isfield(opts,'f_kmeans'); f_kmeans = opts.bool_kmeans; end
if isfield(opts,'f_otsu'); f_otsu = opts.bool_otsu; end
%-------------------------------------------------------------------------%



%== Attempt 1: k-means segmentation + rolling ball transformation ========%
if f_kmeans
    img_binary = agg.seg_kmeans(...
        img,pixsize);
    [moreaggs,choice,img_binary] = ...
        user_input(img,img_binary); % prompt user
    img_binary = imclearborder(img_binary); % clear aggregates on border
else
    choice = 'No';
end

commandwindow;  % return focus to Matlab window



%== Attempt 2: Ostu + rolling ball transformation ========================%
if or(strcmp(choice,'No'), ~f_kmeans)
    if f_otsu
        img_binary = agg.seg_otsu(...
            img,pixsize,minparticlesize,coeffs);
        [moreaggs,choice,img_binary] = user_input(...
            img,img_binary); % prompt user
    else
        choice = 'No'; moreaggs = 1;
    end
    if strcmp(choice,'No'); img_binary = zeros(size(img)); end
end

img_cropped = [];



%== Attempt 3: Manual thresholding with slider UI ========================%
if moreaggs==1
    tools.textheader('slider method');
    
    % Access slider UI, using either:
    %   if 'Yes, but refine' on previous output from user_input fnc.
    %   OR zeros as a start
    img_binary = agg.seg_slider(img, img_binary);
        
    tools.textheader();
end

commandwindow;  % return focus to Matlab window


end






%== USER_INPUT ===========================================================%
%   Prompt the user about whether detection is adequate
%   Author:  Timothy Sipkens, 10-10-2019
function [moreaggs,choice,img_binary] = user_input(img,img_binary)

f = figure(gcf);
f.WindowState = 'maximized'; % maximize figure
tools.imshow_binary(img, img_binary);


%== User interaction =====================================================%
choice = questdlg(['Satisfied with automatic aggregate detection? ',...
    'NOTE: ''Yes, but refine'' will supplement the results with a manual threshold ',...
    'or will allow the user to remove particles.'],...
    'agg detection','Yes','Yes, but refine','No','Yes');

moreaggs = 0; % default, returned if 'Yes' is chosen
if strcmp(choice,'Yes, but refine')
    choice2 = questdlg('How do you want to refine aggregate detection?',...
        'agg detection','More particles or add to existing particles', ...
        'Remove particles','More particles or add to existing particles');
    
    % If more particles, set moreaggs = 1, which will skip ahead to Line 131
    if strcmp(choice2, 'More particles or add to existing particles')
        moreaggs = 1;
        
    % If particles to remove, use the bwselect utility.
    else
        uiwait(msgbox(['Please select (left click) particles ', ...
            'to remove and press enter.']));
        tools.imshow(img_binary);
        img_remove = bwselect;
        img_binary = img_binary - img_remove;
    end
    
elseif strcmp(choice,'No') % skips to the next method
    moreaggs = 1;
end

end


