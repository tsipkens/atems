
% REFINE_CIRCLES    Allows for modification of primary particle sizing.
% Author:           Timothy Sipkens, 2019-07-04
% Note:             Modification is done by moving handles on MATLAB
%                   roi.Circles objects.
%=========================================================================%

function [Data] = refine_circles(img,Data)

radii = Data.radii;
centers = Data.centers;

f = figure; % generate new figure for refine circles step
clf;
imshow(img); % display current image
f.WindowState = 'maximized';

for ii=1:length(radii) % generate a series of roi.Circles objects (with handles)
    h(ii) = images.roi.Circle(gca,'Center',centers(ii,:),'Radius',radii(ii));
end

uicontrol('String','Finished',...
    'Callback','uiresume(gcbf)','Position',[20 20 100 40]);

uiwait; % wait for use to hit button

iv = isvalid(h);
if sum(iv)==0; disp('Figure closed: no update occurred.'); return; end

Data.radii = vertcat(h(iv).Radius); % prepare output
Data.centers = vertcat(h(iv).Center);

close(gcf);

end