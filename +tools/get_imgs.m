
% GET_IMGS  Loads nth image specified in the image reference structure (img_ref)
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function [img,RawImage] = get_imgs(img_ref,n)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('n','var'); n = []; end
if isempty(n); n = 1; end % if image number not specified, use the first one

%-- Read in image --------------------------------------------------------%
RawImage = imread([img_ref.dir,img_ref.fname{n}]);

img.RawImage = RawImage;
img.num = 1;

end

