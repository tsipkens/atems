
% LOAD_IMGS Loads nth image specified in the image structure (or selected in UI).
%           If n is not specified, it will load all of the images. 
%           This can be problematic for large sets of images.
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function [Imgs, imgs, pixsize] = load_imgs(fd, n)

tools.textheader('Loading images');

%-- Parse inputs ---------------------------------------------------------%
% if not image information provided, use a UI to select files
if ~exist('fd','var'); fd = []; end
if isempty(fd); Imgs = get_fileref; end % use UI to get files

if ~isempty(fd)
    if strcmp(fd(1:4), 'http')  % if web resource
        Imgs(1).folder = '';
        Imgs(1).fname = fd;

    elseif isa(fd, 'char')  % get all images in local folder given in Imgs
        Imgs = get_fileref(fd);
    end
end


% if image number not specified, process all of the images.
if ~exist('n','var'); n = []; end
if isempty(n); n = 1:length(Imgs); end
Imgs = Imgs(n);  % option to select only some of the images before read
%-------------------------------------------------------------------------%


%-- Read in image --------------------------------------------------------%
ln = length(n); % number of images

disp('Reading files:');
tools.textbar([0, ln]);
for ii=ln:-1:1 % reverse order to pre-allocate
    Imgs(ii).raw = imread([Imgs(ii).folder, Imgs(ii).fname]);
    Imgs(ii).raw = Imgs(ii).raw(:,:,1);
    tools.textbar([ln - ii + 1, ln])
end
disp(' ');

% crop out footer and get scale from text
Imgs = detect_footer_scale(Imgs);

% format other outputs
imgs = {Imgs.cropped};
pixsize = [Imgs.pixsize];

tools.textheader();  % output footer text

end






%== GET_FILEREF ==========================================================%
%   Loads references to image files, including their name and directory.
%   Populates intitial information to Imgs structure before loading images.
function Imgs = get_fileref(fd)

if ~exist('fd','var'); fd = []; end

flag = 0; % 0: no image loaded; 1: at least one image loaded
% loop continues until at least image is selected or the program is stopped

Imgs.fname = ''; % initialize image reference structure


%-- Get file information -------------------------------------------------%
while flag == 0
    dir_start = 'images'; % initial directory to look for images
    
    % Browse or get file information.
    if isempty(fd) % if no folder, user browses for images (tif,jpg)
        [fname, folder] = uigetfile({'*.tif;*.jpg', 'TEM image (*.tif;*.jpg)'}, ...
            'Select Images', dir_start, 'MultiSelect', 'on');
    else % if folder is given, get all tif files in the folder
        t0 = [ ...  % pattern to match filenames
            dir(fullfile(fd,'*.tif')), ...  % get TIF
            dir(fullfile(fd,'*.jpg'))];  % get JPG
        fname = {t0.name};
        folder = t0(1).folder;
    end
    
    % Format file information for output
    if iscell(fname) % handle a cell array of files
        flag = 1;
        for ii=length(fname):-1:1
            Imgs(ii).fname = fname{ii};
            Imgs(ii).folder = [folder, filesep];
        end
    elseif Imgs.fname==0 % handle when no image was selected
        error('No image selected.');
    else % handle when only one image is selected
        Imgs.fname = fname;
        Imgs.folder = [folder, filesep];
        flag = 1;
    end
end
%-------------------------------------------------------------------------%


end





%== DETECT_FOOTER_SCALE ==================================================%
%   Crops the footer from the image and determines the scale.
function [Imgs, pixsizes] = detect_footer_scale(Imgs)

disp('Looking for footers/scale:');
tools.textbar([0, length(Imgs)]);

for jj=1:length(Imgs)
    
    %== Designed for UBC footer. =========================================%
    % Look for footer as white box. Run OCR to find "*/pix" indicators of pixel size. 
    % When the program reaches a row of only white pixels, removes
    % everything below it (specific to ubc photos). It will do nothing if
    % there is no footer or the footer is not pure white.
    white = 255; % how white is the background of footer?
    footer_found = 0; % flag whether footer was found
    
    f_nm = 1;  % flag indicating nanometers (detected below)
    
    % Search for row satisying 
    f_footrow = sum(Imgs(jj).raw, 2) > ...
    	(0.9 * size(Imgs(jj).raw,2) * white);
    ii = find(f_footrow, 1);  % first 90% white row
    
    if ~isempty(ii)  % if found footer satisyfing above
        Imgs(jj).cropped = Imgs(jj).raw(1:ii-1, :);
        footer  = Imgs(jj).raw(ii:end, :);

        footer_found = 1;  % flag that footer was found

        %-- Detecting magnification and/or pixel size ----------------%
        o1 = ocr(footer);
        Imgs(jj).ocr = o1;

        % Look for pixel size.
        pixsize_end = strfind(o1.Text,' nm/pix')-1;
        if isempty(pixsize_end) % if not found, try nmlpix
            pixsize_end = strfind(o1.Text,' nmlpix')-1;

            if isempty(pixsize_end)
                pixsize_end = strfind(o1.Text,' pm/pix')-1; % micrometer

                if isempty(pixsize_end)
                    pixsize_end = strfind(o1.Text,' pmlpix')-1;
                end
                f_nm = 0;
            end
        end

        % Interpret OCR text and compute pixel size.
        pixsize_start = strfind(o1.Text,'Cal')+5;
        Imgs(jj).pixsize = str2double(...
            o1.Text(pixsize_start:pixsize_end));

        % If given in micrometers, convert.
        if f_nm==0; Imgs(jj).pixsize = Imgs(jj).pixsize*1e3; end
    end
    
    
    % If above method failed, look for black text on image.
    if footer_found == 0
        bw1 = im2bw(1 - double(Imgs(jj).raw) ./ ...
            max(max(double(Imgs(jj).raw))), 0.98);
        bw1 = bwareaopen(bw1, 350);
        
        footer = bw1;
        
        % Run OCR to get scalebar length.
        % Less reliable than above method and is worth spot checking.
        o1 = ocr(footer);
        Imgs(jj).ocr = o1;
        sc_end = strfind(o1.Text,' nm')-1;
        
        if ~isempty(sc_end) % if text found
            sc_start = 1;
            sc_length = str2double(...
                o1.Text(sc_start:sc_end));  % length of scale bar in nm

            rp = regionprops(bw1);
            ar = [rp.BoundingBox];
            ar = reshape(ar', [4, length(ar)/4])';
            ar = ar(:,3) ./ ar(:,4);  % arrive at aspect ratio
            [~, ar_max] = max(ar); len = rp(ar_max).BoundingBox(3);  % pixel length of scale bar
            Imgs(jj).pixsize = sc_length / len;
            
            % If given in micrometers, convert.
            if f_nm==0; Imgs(jj).pixsize = Imgs(jj).pixsize * 1e3; end

            Imgs(jj).cropped = Imgs(jj).raw;  % scale bar in image, cannot crop
            
            footer_found = 1; % mark that text has been found
        end
    end
    
    % If both of the above methods fail.
    if footer_found == 0
        Imgs(jj).cropped = Imgs(jj).raw;
        Imgs(jj).pixsize = NaN;  % return NaN if nothing found
    end
    
    tools.textbar([jj, length(Imgs)]);
end

pixsizes = [Imgs.pixsize];

% If the pixel size / footer was not found for a number of images.
if any(isnan(pixsizes))
    warning(['One or more footers or scales not found.', ...
        'In these cases, cropped image is raw image. ', ...
        'Assign pixel size manually or using ui_scale_bar.m.']);
    disp(' ');
end

end





