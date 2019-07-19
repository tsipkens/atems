function binaryImage = Lasso_fnc(Cropped_im)
% Semi-automatic detection of the aggregates on TEM images
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% This function allows user to draw an approximate boundary around the
% particle. Region of interest (ROI))

% Updated by Yiling Kang on May. 10, 2018
% Updates/QOL Changes:
%   - Asks user if their lasso selection is correct before applying the
%     data
%   - QOL - User will not have to restart program if they mess up the lasso

fontsize = 10;
%% Displaying cropped image
figure; imshow(Cropped_im);
title('Original CROPPED Image', 'FontSize', fontsize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.

%% Freehand drawing. Selecting region of interest (ROI)

drawing_correct = 0; % this variable is used to check if the user drew the lasso correctly
while drawing_correct == 0 
   message = sprintf('Please draw an approximate boundary around the aggregate.\nLeft click and hold to begin drawing.\nLift mouse button to finish');
   uiwait(msgbox(message));
   hFH = imfreehand(); 
   finished_check = questdlg('Are you satisfied with your drawing?','Lasso Complete?','Yes','No','No');
            % if user is happy with their selection...
            if strcmp(finished_check, 'Yes')
                drawing_correct = 1;
            % if user would like to redo their selection...
            else
                delete(hFH);
            end     
end


%% Create a binary masked image from the ROI object
binaryImage = hFH.createMask();
