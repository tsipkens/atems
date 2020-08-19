
% REFINE_CIRCLES    Allows for modification of primary particle sizing.
% Author:           Timothy Sipkens, 2019-07-04
% Note:             Modification is done by moving handles on MATLAB
%                   roi.Circles objects.
%=========================================================================%

function [Data] = refine_circles(img, Data)

% generate new figure for refine circles step
f0 = figure;
f0.WindowState = 'maximized';

% display current image
imagesc(img);
colormap gray; axis image off;


% get particle properties
radii = Data.radii;
centers = Data.centers;
pixsize = Data.dp./(2.*Data.radii); % get pixel size from radii/dp ratio


% generate a series of roi.Circles objects (with handles)
for ii=1:length(radii)
    h(ii) = images.roi.Circle(gca,'Center',centers(ii,:),'Radius',radii(ii));
end

uicontrol('String','Finished',...
    'Callback','uiresume(gcbf)','Position',[20 20 100 40]);

uiwait; % wait for use to hit button

iv = isvalid(h);
if sum(iv)==0; disp('Figure closed: no update occurred.'); return; end


% update data parameters for output
Data.radii = vertcat(h(iv).Radius); % prepare output
Data.centers = vertcat(h(iv).Center);
Data.dp = 2.*pixsize.*Data.radii;

close(f0);

end