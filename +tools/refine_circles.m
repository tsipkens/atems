
% REFINE_CIRCLES    Allows for modification of primary particle sizing.
% Author:           Timothy Sipkens, 2019-07-04
% Note:             Modification is doen by moving handles on MATLAB
%                   roi.Circles objects.
%=========================================================================%

function [dp] = refine_circles(img,centers,radii)

figure;
imshow(img); % display current image

for ii=1:length(radii) % generate a series of roi.Circles objects (with handles)
    h(ii) = images.roi.Circle(gca,'Center',centers(ii,:),'Radius',radii(ii));
end

figure(gcf); % display current figure
m = msgbox('Modify circles using the handles and click OK when complete.');
uiwait(m); % display message box and wait for the user to click ok

dp.radii = [h.Radius]'; % prepare output
dp.centers = reshape([h.Center],[2,length(h)])';

close(gcf);

end
