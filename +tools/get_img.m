
% GET_IMG   Loads nth image specified in the image reference structure (img_ref)
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function img = get_img(img_ref,n)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('n','var'); n = []; end
if isempty(n); n = 1; end % if image number not specified, use the first one

%-- Read in image --------------------------------------------------------%
if img_ref.num==1
    img = imread([img_ref.dir,img_ref.files]);
else
    img = imread([img_ref.dir,img_ref.files{n}]);
end

end

