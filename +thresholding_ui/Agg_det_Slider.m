function [NewBW_lasoo,rect,Thresh_slider_in] = Agg_det_Slider(Cropped_image,opts_crop) 
% Semi-automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% This function applies background correction and thresholding on the
% user-defined portion of the image.
% Slider method

%-- Parse input ---------------------%
if ~exist('opts_crop','var')
    opts_crop = 1;
elseif isempty(opts_crop)
    opts_crop = 1;
end


global Binary_Image_4 binaryImage Thresh_slider_in

if opts_crop
    uiwait(msgbox('Please crop the image around missing particle'));
    [Cropped_img_int, rect] = imcrop(Cropped_image); % user crops image
else
	Cropped_img_int = Cropped_image; % originally bypassed in Kook code
    rect = [];
end

%% Step 1: Image refinment

%% Step 1-1: Apply Lasso tool
binaryImage = thresholding_ui.Lasso_fnc(Cropped_img_int);

%% Step 1-2: Refining background brightness
Refined_surf_img = thresholding_ui.Background_fnc(binaryImage,Cropped_img_int);

%% Step 2: Thresholding
Thresh_slider_in = Refined_surf_img;
f = figure;
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
hax = axes('Units','pixels');
imshow(Thresh_slider_in);

% global  Filtered_Image_2
level = graythresh(Thresh_slider_in);
hst = uicontrol('Style', 'slider',...
    'Min',0-level,'Max',1-level,'Value',.5-level,...
    'Position', [140 480 120 20],...
    'Callback', {@thresholding_ui.Thresh_Slider});
get(hst,'value') % add a slider uicontrol
% implemented as a local function

% add a text uicontrol to label the slider
uicontrol('Style','text',...
    'Position', [140 500 120 20],...
    'String','Threshold level')

% Pause debugging while user changes the threshold level by moving the slider
h = uicontrol('Position',[100 350 200 40],'String','Finished',...
    'Callback','uiresume(gcbf)');
message = sprintf('Move the slider to the right or left to change threshold level\nWhen finished, click on continute');
uiwait(msgbox(message));
disp('Waiting for the user to apply the threshold to the image');
uiwait(gcf);
disp('Thresholding is applied');
close(f);

%%
uiwait(msgbox('Please selects (left click) particles satisfactorily detected; and press enter'));
Binary_int = bwselect(Binary_Image_4,8);
NewBW_lasoo = ~Binary_int;
% NewBW_lasoo = Binary_int; % originally this in the Kook code


end
