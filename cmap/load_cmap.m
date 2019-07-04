
% LOAD_CMAP     Loads colormaps with the name corredponding
% Compiled by:  Timothy Sipkens
% Note:         Citations for colormaps can be found in the associated
%               README.md file.
%=========================================================================%

function cm = load_cmap(str,n)

load([str,'.mat']); % load corresponding colormap
    % colormaps are loaded as 'cm' variable into workspace

    
%-- Parse inputs ---------------------------------------------------------%
p = size(cm,1);
if ~exist('n','var'); n = []; end
if isempty(n); n = p; end


%-- Modify the colormap, if n is specified -------------------------------%
n = min(n,p); % limit number of colors to that provided in the colormap itself
cm = interp1(1:p, cm, linspace(1,p,n), 'linear');


end

