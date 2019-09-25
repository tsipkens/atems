function [img_binary,rect,thresh_slider_in,img_cropped] = Agg_det_Slider(img,bool_crop) 
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
if ~exist('bool_crop','var'); bool_crop = []; end
if isempty(bool_crop); bool_crop = 1; end

%-- Crop image ----------------------%
if bool_crop
    uiwait(msgbox('Please crop the image around missing particle'));
    [img_cropped, rect] = imcrop(img); % user crops image
else
	img_cropped = img; % originally bypassed in Kook code
    rect = [];
end

%== Step 1: Image refinment ==============================================%
%-- Step 1-1: Apply Lasso tool -------------------------------------------%
img_binary = thresholding_ui.lasso_fnc(img_cropped);

%-- Step 1-2: Refining background brightness -----------------------------%
img_refined = thresholding_ui.background_fnc(img_binary,img_cropped);


%== Step 2: Thresholding =================================================%
thresh_slider_in = img_refined;
f = figure;
screen_size = get(0,'Screensize');
set(gcf,'Position',screen_size); % maximize figure

% axis_size = round(0.7*min(screen_size(3:4)));
% hax = axes('Units','Pixels','Position',...
%     [min(screen_size(3:4)-100-axis_size),...
%     50,axis_size,axis_size]);
hax = axes('Units','Pixels');
imshow(thresh_slider_in);

level = graythresh(thresh_slider_in);
hst = uicontrol('Style', 'slider',...
    'Min',0-level,'Max',1-level,'Value',.5-level,...
    'Position', [20 390 150 15],...
    'Callback', {@thresholding_ui.thresh_slider,hax,thresh_slider_in,img_binary});
get(hst,'value'); % add a slider uicontrol

uicontrol('Style','text',...
    'Position', [20 370 150 15],...
    'String','Threshold level');
        % add a text uicontrol to label the slider

%-- Pause program while user changes the threshold level -----------------%
h = uicontrol('Position',[20 320 200 30],'String','Finished',...
    'Callback','uiresume(gcbf)');
message = sprintf('Move the slider to the right or left to change threshold level\nWhen finished, click on continute');
uiwait(msgbox(message));
disp('Waiting for the user to apply the threshold to the image');
uiwait(gcf);
close(gcf);
disp('Thresholding is applied.');

%== Select particles and format output ===================================%
uiwait(msgbox('Please selects (left click) particles satisfactorily detected; and press enter'));
img_binary = bwselect(Binary_Image_4,8);
img_binary = ~img_binary; % formatted for PCA, other codes should reverse this


end
