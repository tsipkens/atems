
% IMREAD  A simpler wrapper to load all images in a folder.
%  
%  IMGS = tools.imread(FD) reads in all of the images in the folder
%  specified by the string FD. Output is a cell of images, IMGS.
%  
%  IMGS = tools.imread(FD,N) reads the subset of images specified 
%  by indices in N.
%  
%  AUTHOR: Timothy Sipkens, 2021-05-14

function imgs = imread(fd, n)

tools.textheader('Loading images');

%-- Parse inputs ---------------------------------------------------------%
% If not image information provided, use a UI to select files
dname = [ ...  % pattern to match filenames
    dir(fullfile(fd, '*.tif')), ...  % get TIF
    dir(fullfile(fd, '*.jpg')), ...  % get JPG
    dir(fullfile(fd, '*.png'))];  % get PNG
fname = {dname.name};

% If image number not specified, process all of the images.
if ~exist('n','var'); n = []; end
if isempty(n); n = 1:length(fname); end
fname = fname(n);  % option to select only some of the images before read
%-------------------------------------------------------------------------%


%-- Read in image --------------------------------------------------------%
ln = length(n); % number of images

disp('Reading files:');
tools.textbar([0, ln]);
for ii=ln:-1:1 % reverse order to pre-allocate
    imgs{ii} = imread([fd, filesep, fname{ii}]);
    imgs{ii} = imgs{ii}(:,:,1);
    tools.textbar([ln - ii + 1, ln])
end
disp(' ');
%-------------------------------------------------------------------------%


tools.textheader();


end

