
% UI_SCALE_BAR  Detect the pixel size using a simple UI.
%  Adaptated from: PCM code by Dastanpour et al. 
%  (https://github.com/unatriva/UBC-PCM/blob/master/PCM_Main_Code_v5.m)
% 
%  [!] Operates on raw images, which can be specified as a cell array.
%  Otherwise, provide input as Imgs structure.
%  
%  [PIXSIZES] = tools.ui_scale_bar(IMG) applies the method to the
%  single, raw image specified by IMG. PIXSIZES will be a scalar.
%  
%  [PIXSIZES] = tools.ui_scale_bar({IMGS}) applies the UI method to all of
%  the raw images provided in the cell array. PIXSIZES will be an array of
%  the same length as {IMGS}.
%  
%  [PIXSIZES] = tools.ui_scale_bar(IMGS) extracts the raw images from an
%  input Imgs structure and applies the UI method. PIXSIZES will be an
%  array of the same length as the number of entries in the IMGS structure.
%  
%  [PIXSIZES] = tools.ui_scale_bar(...,N) applies the UI method to the
%  entires specified by N. N is a vector containing the integers of the
%  entries to consider. The default is to apply the UI method to all of the
%  inputs, the same as is N = 1:length(IMGS). For example, to apply the UI
%  method to the first and third images, N = [1,3]. The output PIXSIZES
%  will be the same lengths as N, containing the pixel sizes for only the
%  select images in the order prescribed by N. 

function [pixsizes] = ui_scale_bar(imgs, n)

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs)
    Imgs = imgs;
    imgs = {Imgs.raw}; % use raw image
end
if ~iscell(imgs); imgs = {imgs}; end

if ~exist('n', 'var'); n = []; end
if isempty(n); n = 1:length(imgs); end

imgs = imgs(n);
%-------------------------------------------------------------------------%


disp('Getting image scales...');

f0 = figure;
f0.WindowState = 'maximized'; % maximize the figure window

pixsizes = zeros(length(imgs), 1); % initialize pixel sizes

for ii=1:length(imgs) % loop through images
    
    tools.imshow(imgs{ii}); % show raw image

    uiwait(msgbox('Please crop around the scale...'))
    img_bar = imcrop(); % crop image around scale bar

    % User chooses two points at the edges of the scale bar.
    tools.imshow(img_bar);
    colormap(gray); axis image; axis off;
    uiwait(msgbox(['Click on a point at the start (left) of the scale bar, ', ...
        'then on a point at the end (right) of the scale bar...']));
    [x, y] = ginput(2); % get ends of bar

    % Calculate number of pixels of magnification bar
    len = abs(x(2) - x(1));
    line([x(1),x(2)], [y(1),y(1)], 'linewidth', 3);

    % Execute the user input.
    bar_scale = str2double(cell2mat(...
        inputdlg('Specify the length of the scale bar in nm:', ...
        'Length', 1, {'100'})));
    pixsizes(ii) = bar_scale / len;
    
end

close(f0); % close figure

disp('Complete.');
disp(' ');
        
end

