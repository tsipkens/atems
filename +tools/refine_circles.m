
% REFINE_CIRCLES    Allows for modification of primary particle sizing.
% Author:           Timothy Sipkens, 2019-07-04
% Note:             Modification is done by moving handles on MATLAB
%                   roi.Circles objects.
%=========================================================================%

function [dp] = refine_circles(img,dp)

radii = dp.radii;
centers = dp.centers;

figure;
imshow(img); % display current image

for ii=1:25%length(radii) % generate a series of roi.Circles objects (with handles)
    h(ii) = images.roi.Circle(gca,'Center',centers(ii,:),'Radius',radii(ii));
end

uicontrol('String','Finished',...
    'Callback','uiresume(gcbf)','Position',[20 20 60 20]);

uiwait; % wait for use to hit button

iv = isvalid(h);
if sum(iv)==0; disp('Figure closed: no update occurred.'); return; end

dp.radii = vertcat(h(iv).Radius); % prepare output
dp.centers = reshape(vertcat(h(iv).Center),[2,sum(iv)])';

close(gcf);

end