
% WRITE_IMAGES Saves images specified in imgs.
% Author: Timothy Sipkens, 2019-11-26
%=========================================================================%

function [] = write_images(imgs,fnames,foldname)

%-- Parse inputs ---------------------------------------------------------%
if ~iscell(imgs); imgs = {imgs}; end
if ~exist('foldname','var'); foldname = []; end
if isempty(foldname); foldname = 'images'; end
%-------------------------------------------------------------------------%


if ~exist(foldname,'dir') % check if folder exists
   mkdir(foldname); % create the folder if it does not exist
end

for ii=1:length(imgs)
    imwrite(imgs{ii}, [foldname,filesep,fnames{ii}]);
end

end

