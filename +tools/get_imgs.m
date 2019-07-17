
% GET_IMGS  Loads nth image specified in the image reference structure (img_ref)
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function [imgs,RawImage] = get_imgs(img_ref,n)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('n','var'); n = []; end
if isempty(n); n = 1:length(img_ref.fname); end
    % if image number not specified, use the first one

%-- Read in image --------------------------------------------------------%
for ii=1:length(n)
    imgs(ii).fname = img_ref.fname{ii};
    imgs(ii).RawImage = imread([img_ref.dir,img_ref.fname{n(ii)}]);
end

RawImage = imgs(1).RawImage;

end

