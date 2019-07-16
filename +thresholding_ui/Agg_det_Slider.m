function [binary_int,rect,thresh_slider_in] = Agg_det_Slider(img_cropped,opts_crop) 
% Semi-automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% This function applies background correction and thresholding on the
% user-defined portion of the image.
% Slider method

global Binary_Image_4

%-- Parse input ---------------------%
if ~exist('opts_crop','var'); opts_crop = []; end
if isempty(opts_crop); opts_crop = 1; end

%-- Crop image ----------------------%
if opts_crop
    uiwait(msgbox('Please crop the image around missing particle'));
    [img_cropped_int, rect] = imcrop(img_cropped); % user crops image
else
	img_cropped_int = img_cropped; % originally bypassed in Kook code
    rect = [];
end

%== Step 1: Image refinment ==============================================%
%-- Step 1-1: Apply Lasso tool -------------------------------------------%
img_binary = thresholding_ui.lasso_fnc(img_cropped_int);

%-- Step 1-2: Refining background brightness -----------------------------%
img_refined = thresholding_ui.background_fnc(img_binary,img_cropped_int);

%-- Step 2: Thresholding -------------------------------------------------%
thresh_slider_in = img_refined;
f = figure;
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
hax = axes('Units','pixels');
imshow(thresh_slider_in);

level = graythresh(thresh_slider_in);
hst = uicontrol('Style', 'slider',...
    'Min',0-level,'Max',1-level,'Value',.5-level,...
    'Position', [140 480 120 20],...
    'Callback', {@thresholding_ui.thresh_slider,thresh_slider_in,img_binary});
get(hst,'value') % add a slider uicontrol

uicontrol('Style','text',...
    'Position', [140 500 120 20],...
    'String','Threshold level') % add a text uicontrol to label the slider

%-- Pause program while user changes the threshold level -----------------%
h = uicontrol('Position',[100 350 200 40],'String','Finished',...
    'Callback','uiresume(gcbf)');
message = sprintf('Move the slider to the right or left to change threshold level\nWhen finished, click on continute');
uiwait(msgbox(message));
disp('Waiting for the user to apply the threshold to the image');
uiwait(gcf);
disp('Thresholding is applied');
close(f);

%== Select particles and format output ===================================%
uiwait(msgbox('Please selects (left click) particles satisfactorily detected; and press enter'));
binary_int = bwselect(Binary_Image_4,8);
binary_int = ~binary_int; % formatted for PCA, other codes should reverse this


end
