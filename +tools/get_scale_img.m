
function [img,pixsize] = get_scale_img(img)

%% Step 1-3: Crop footer away
% when the program reaches a row of only white pixels, removes
% everything below it (specific to ubc photos). It will do nothing if
% there is no footer or the footer is not pure white.
footer_found = 0;
for i = 1:size(img.RawImage,1)
    if sum(img.RawImage(i,:)) == size(img.RawImage,2)*255 && ...
            footer_found == 0

        FooterEdge   = i;
        footer_found = 1;
        img.Cropped  = img.RawImage(1:FooterEdge-1, :);
        img.Footer  = img.RawImage(FooterEdge:end, :);

    end
end

if footer_found == 0
    img.Cropped = img.RawImage;
end


%% Step 1-2: Detecting Magnification and/or pixel size
img.ocr = ocr(img.Footer);
pixsize_end = strfind(img.ocr.Text,' nm/pix')-1;
if isempty(pixsize_end) % if not found, try nmlpix
    pixsize_end = strfind(img.ocr.Text,' nmlpix')-1;
end
pixsize_start = strfind(img.ocr.Text,'Cal')+5;
pixsize = str2double(img.ocr.Text(pixsize_start:pixsize_end));

disp(['Pixel size: ',num2str(pixsize),' nm/pixel']);

end



