
% WRITE_IMAGES Saves images specified in imgs.
% Author: Timothy Sipkens, 2019-11-26
%=========================================================================%

function [] = write_images(imgs, fnames, folder)

%-- Parse inputs ---------------------------------------------------------%
if ~iscell(imgs); imgs = {imgs}; end
if ~exist('folder','var'); folder = []; end
if isempty(folder); folder = 'temp'; end
%-------------------------------------------------------------------------%


if isfolder(folder) % check if folder exists
   mkdir(folder); % create the folder if it does not exist
end

for ii=1:length(imgs)
    imwrite(imgs{ii}, [folder, filesep, fnames{ii}]);
end

end

