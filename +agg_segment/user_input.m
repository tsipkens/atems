
% USER_INPUT  Prompt the user about whether detection is adequate
% Author:     Timothy Sipkens
% Date:       10-10-2019
%=========================================================================%

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

