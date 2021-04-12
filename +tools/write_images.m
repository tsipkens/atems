
% WRITE_IMAGES Saves images specified in imgs.
% Author: Timothy Sipkens, 2019-11-26
%=========================================================================%

function [fnames] = write_images(imgs, fnames, fd, ext)

%-- Parse inputs ---------------------------------------------------------%
if ~iscell(imgs); imgs = {imgs}; end

if ~iscell(fnames); fnames = {fnames}; end

if ~exist('fd', 'var'); fd = []; end
if isempty(fd); fd = 'temp'; end

if ~exist('ext', 'var'); ext = []; end  % if file extension not specified
if isempty(ext); ext = 'PNG'; end
%-------------------------------------------------------------------------%


if ~isfolder(fd) % check if folder exists
   mkdir(fd); % create the folder if it does not exist
end

if ~isempty(ext)
    for ii=1:length(imgs)
        [~, fn1] = fileparts(fnames{ii});
        fnames{ii} = [fn1, '.', ext];
    end
end

for ii=1:length(imgs)
    imwrite(imgs{ii}, [fd, filesep, fnames{ii}]);
end

end

