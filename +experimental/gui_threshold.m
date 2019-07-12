
function gui_threshold()

clear;
close all;

img_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
img = tools.get_imgs(img_ref); % load a single image
img = tools.get_footer_scale(img); % get footer for selected image


%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[500,200,700,500]);

%  Construct the components.
ha = axes('Units','Pixels','Position',[50,50,500,400]);
imshow(img.Cropped);

hrestart = uicontrol('Style','pushbutton',...
   'String','Restart','Position',[580,440,100,25]); 
hcrop = uicontrol('Style','pushbutton','String','Crop',...
   'Position',[580,400,100,25],'Callback',{@cropper,img});
htext = uicontrol('Style','text','String','Modify thresholding:',...
   'Position',[580,320,100,25]);
hslider = uicontrol('Style','slider',...
   'Value',0.5,'Position',[580,310,100,15],'Callback',{@thresh_mod});
hthresh = uicontrol('Style','pushbutton','String','Apply Otsu',...
   'Position',[580,360,100,25],'Callback',{@thresholder,hslider});
hfinished = uicontrol('Style','pushbutton','String','Finished',...
   'Position',[580,250,100,25],'Callback','uiresume(gcbf)');
% align([hcrop,hmesh,hcontour,htext,hpopup,hfinished],'Center','None');

axes(ha);
setappdata(gca,'image',img.Cropped);
setappdata(gca,'pos',[1,1]);

f.Visible = 'on';

uiwait;

data = getappdata(gca);
close(gcf);


function cropper(src,event,img)

    roi0 = drawrectangle(gca);
    r = round(roi0.Position);
    im_crop = img.Cropped(...
        r(2):(r(2)+r(4)),r(1):(r(1)+r(3)));
    imshow(im_crop);
    uicontrol('Style','pushbutton','String','Uncrop',...
       'Position',[580,440,100,25],'Callback',{@uncropper,img});

    setappdata(gca,'image',im_crop);
    setappdata(gca,'pos',[r(2),r(1)]);

    disp('Image cropped.');
    uiwait;

end


function uncropper(src,event,img)

    imshow(img.Cropped);
    uicontrol('Style','pushbutton','String','Crop',...
       'Position',[580,440,70,25],'Callback',{@cropper,img});

    setappdata(gca,'image',img.Cropped);
    setappdata(gca,'pos',[1,1]);

    disp('Image uncropped.');
    uiwait;

end


function thresholder(src,event,hslider)

    data = getappdata(gca);
    img = data.image;

    level = graythresh(img);
    im_thresh = (img>(level.*255));
    imshow(im_thresh);

    hslider.Value = level;

    setappdata(gca,'image_thresh',im_thresh);
    setappdata(gca,'pos_thresh',data.pos);
    setappdata(gca,'level_thresh',level);

end


function thresh_mod(src,event)

    data = getappdata(gca);
    img = data.image;

    level = hslider.Value;

    im_thresh = (img>(level.*255));
    imshow(im_thresh);

    setappdata(gca,'image_thresh',im_thresh);
    setappdata(gca,'pos_thresh',data.pos);
    setappdata(gca,'level_thresh',level);

end



end

