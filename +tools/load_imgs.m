
% LOAD_IMGS Loads nth image specified in the image structure (or selected in UI).
%           If n is not specified, it will load all of the images. 
%           This can be problematic for large sets of images.
% Author:   Timothy Sipkens, 2019-07-04
%=========================================================================%

function [Imgs, imgs] = load_imgs(Imgs, n)

%-- Parse inputs ---------------------------------------------------------%
% if not image information provided, use a UI to select files
if ~exist('Imgs','var'); Imgs = []; end
if isempty(Imgs); Imgs = tools.get_files; end % use UI to get files
if isa(Imgs, 'char'); Imgs = tools.get_files(Imgs); end % get all images in folder given in Imgs

% if image number not specified, use the first one
if ~exist('n','var'); n = []; end
if isempty(n); n = 1:length(Imgs); end


%-- Read in image --------------------------------------------------------%
for ii=length(n):-1:1
    Imgs(ii).raw = imread([Imgs(ii).folder, filesep, Imgs(ii).fname]);
end

% crop out footer and get scale from text
Imgs = tools.get_footer_scale(Imgs);

% output cropped image
imgs = {Imgs.cropped};

end

