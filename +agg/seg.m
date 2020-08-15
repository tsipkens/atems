
% SEG	Sequential attempts at semi-automatic detection of the aggregates on TEM images.
%           Attempts k-means + rolling ball, Otsu + rolling ball, slider
%           thresholding. Acts as a wrapper function for implementing 
%           several other seg*.m methods
% Author:   Ramin Dastanpour, Steven N. Rogak
%           Developed at the University of British Columbia
% Modified: Timothy Sipkens, 2019
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

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

%-- Partially parse name-value pairs --%
if ~exist('opts','var'); opts = []; end
%-------------------------------------------------------------------------%


imgs_binary = cell(length(imgs),1); % pre-allocate
for ii=1:length(imgs) % loop through provided images
    
    disp(['[== IMAGE ',num2str(ii),' =================================]']);
    
    %-- Initialize parameters --------------------------------------------%
    %   use defaults defined in seg instead
    
    %-- Run slider to obtain binary image --------------------------------%
    [img_binary,~,~,~] = seg1(...
        imgs{ii},pixsize(ii),[],[],...
        opts); % includes removing aggregates from border
    imgs_binary{ii} = img_binary;
    
    if ~exist('temp', 'dir')
       mkdir('temp')
    end
    imwrite(imgs_binary{ii},['temp/',num2str(ii),'.tiff']);
        % write binaries to temporary file
    
    disp('Completed thresholding.');
    disp(' ');
    
end

close(gcf); % close image with overlaid da
disp('Complete.');
disp(' ');

end





%== SEG1 =================================================================%
%   Segments a single image by attempting multiple methods. 
%   Author:  Timothy Sipkens, 10-10-2019
function [img_binary,img_cropped,agg_binary_bin,agg_cropped_bin] = ...
    seg1(img,pixsize,minparticlesize,coeffs,opts) 

agg_binary_bin = {};    % Bin of binary aggregate images
agg_cropped_bin = {};   % Bin of cropped aggregated images


%== Parse inputs =========================================================%
if ~exist('pixsize','var'); pixsize = []; end
if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

bool_kmeans = 1;
bool_otsu = 1;
if ~exist('opts','var'); opts = []; end
if isfield(opts,'bool_kmeans'); bool_kmeans = opts.bool_kmeans; end
if isfield(opts,'bool_otsu'); bool_otsu = opts.bool_otsu; end
%-------------------------------------------------------------------------%


%== Attempt 1: k-means segmentation + rolling ball transformation ========%
if bool_kmeans
    img_binary = agg.seg_kmeans2(...
        img,pixsize);
    [moreaggs,choice] = ...
        user_input(img,img_binary); % prompt user
    img_binary = imclearborder(img_binary); % clear aggregates on border
else
    choice = 'No';
end



%== Attempt 2: Ostu + rolling ball transformation ========================%
if or(strcmp(choice,'No'),~bool_kmeans)
    if bool_otsu
        img_binary = agg.seg_otsu_rb(...
            img,pixsize,minparticlesize,coeffs);
        [moreaggs,choice] = user_input(...
            img,img_binary); % prompt user
    else
        choice = 'No'; moreaggs = 1;
    end
    if strcmp(choice,'No'); img_binary = zeros(size(img)); end
end

img_cropped = [];



%== Attempt 3: Manual thresholding =======================================%
while moreaggs==1
    [img_temp,rect,~,img_cropped] = agg.seg_slider(img,1);
        % used previously cropped image
        % img_temp temporarily stores binary image
    
    [~,f] = tools.plot_binary_overlay(...
        img_cropped,img_temp);
    
    choice2 = questdlg('Satisfied with aggregate detection? If not, try drawing an edge around the aggregate manually...',...
        'Agg detection','Yes','No','Yes');
    
    close(f);
    
    
    %== Attempt 4: Manual thresholding, again ============================%
    if strcmp(choice2,'No')
        [img_temp,rect,~,img_cropped] = agg.seg_slider(img,1);
            % image is stored in a temporary image
    end
    
    agg_binary_bin  = [agg_binary_bin, img_temp];
    agg_cropped_bin = [agg_cropped_bin, img_cropped];
    
    %-- Subsitute rectangle back into orignal image ----------------------%
    if isempty(img_binary)
        img_binary = ones(size(img));
    end
    rect = round(rect);
    size_temp = size(img_temp);
    
    inds1 = rect(2):(rect(2)+size_temp(1)-1);
    inds2 = rect(1):(rect(1)+size_temp(2)-1);
    img_binary(inds1,inds2) = ...
        or(img_binary(inds1,inds2),img_temp);
    
    %-- Query user -------------------------------------------------------%
    h = figure(gcf);
    tools.plot_binary_overlay(img,img_binary);
    f = gcf;
    f.WindowState = 'maximized'; % maximize figure
    
    choice = questdlg('Are there any particles not detected?',...
        'Missing particles','Yes','No','No');
    if strcmp(choice,'Yes')
        moreaggs=1;
    else
        moreaggs=0;
    end
    
    close(h);
end

end






%== USER_INPUT ===========================================================%
%   Prompt the user about whether detection is adequate
%   Author:  Timothy Sipkens, 10-10-2019
function [moreaggs,choice,img_binary] = user_input(img,img_binary)

h = figure(gcf);
tools.plot_binary_overlay(img,img_binary);
f = gcf;
f.WindowState = 'maximized'; % maximize figure


%== User interaction =====================================================%
choice = questdlg(['Satisfied with automatic aggregate detection? ',...
    'You will be able to delete non-aggregate noises and add missing particles later. ',...
    'If not, other methods will be used'],...
    'agg detection','Yes','Yes, but more particles or refine','No','Yes');

moreaggs = 0; % default, returned is 'Yes' is chosen
if strcmp(choice,'Yes, but more particles or refine')
    choice2 = questdlg('How do you want to refine aggregate detection?',...
        'agg detection','More particles','Reduce noise','More particles');
    if strcmp(choice2,'More particles')
        moreaggs = 1;
    else
        uiwait(msgbox('Please selects (left click) particles satisfactorily detected and press enter'));
        img_binary_int = bwselect(~img_binary,8);
        img_binary = ~img_binary_int;
    end
    
elseif strcmp(choice,'No') % semi-automatic or manual methods will be used
    img_binary = [];
    moreaggs = 1;
end

close(h);

end


