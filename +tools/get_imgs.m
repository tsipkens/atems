
% GET_IMGS  Loads nth image specified in the image reference structure (img_ref)
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function [Imgs,img_raw] = get_imgs(Imgs_ref,n)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('n','var'); n = []; end
if isempty(n); n = 1:length(Imgs_ref.fname); end
    % if image number not specified, use the first one

%-- Read in image --------------------------------------------------------%
for ii=length(n):-1:1
    Imgs(ii).fname = Imgs_ref.fname{ii};
    Imgs(ii).raw = imread([Imgs_ref.dir,Imgs_ref.fname{n(ii)}]);
end

img_raw = Imgs(1).raw;

end

