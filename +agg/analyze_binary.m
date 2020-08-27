
% ANALYZE_BINARY Label and analyze a binary mask to determine aggregate properties (e.g. Rg).
% Author:  Timothy Sipkens
%=========================================================================%

function [Aggs] = analyze_binary(imgs_binary, imgs, pixsize, fname, f_plot)

%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs_binary) % consider case that structure is given as input
    Imgs = imgs;
    imgs = {Imgs.cropped};
    pixsize = [Imgs.pixsize];
    fname = {Imgs.fname};
else
    % consider case that a single image is given
    if ~iscell(imgs_binary); imgs_binary = {imgs_binary}; end
    if ~iscell(imgs); imgs = {imgs}; end
end

if ~exist('pixsize','var'); pixsize = []; end
if isempty(pixsize); pixsize = ones(size(imgs)); end

if ~exist('fname','var'); fname = []; end
if isempty(fname); fname = cell(size(imgs)); end

% Flag for whether to show progress in a figure.
if ~exist('f_plot','var'); f_plot = []; end
if isempty(f_plot); f_plot = 1; end
%-------------------------------------------------------------------------%


if f_plot==1; f0 = figure; end % intialize a new figure to show progress
Aggs = struct([]); % initialize Aggs structure
id = 0;

disp('Calculating aggregate areas...');
for ii=1:length(imgs_binary) % loop through provided images

    img_binary = imgs_binary{ii};
    img = imgs{ii};

    CC = bwconncomp(imgs_binary{ii}); % find seperate aggregates
    naggs = CC.NumObjects; % count number of aggregates

    Aggs0 = struct([]); % re-initialize Aggs0 structure
    Aggs0(naggs).fname = '';
        % pre-allocate new space for aggregates and assign filename


    %== Main loop to analyze each aggregate ==============================%
    if f_plot==1; tools.imshow_binary(img, img_binary); end
    for jj = 1:naggs % loop through number of found aggregates
        
        id = id + 1; % increment global index counter
        Aggs0(jj).id = id;
        Aggs0(jj).img_id = ii;
        
        Aggs0(jj).fname = fname{ii};
        Aggs0(jj).pixsize = pixsize(ii);

        Aggs0(jj).image = img;
            % store image that the aggregate occurs in

        %-- Step 3-2: Prepare an image of the isolated aggregate ---------%
        img_binary = zeros(size(img_binary));
        img_binary(CC.PixelIdxList{1,jj}) = 1;
        Aggs0(jj).binary = img_binary;

        [~, ~, Aggs0(jj).rect] = ...
            autocrop(img, img_binary);
            % get a cropped version of the aggregate
            % 'autocrop' method included below


        %== Compute aggregate dimensions/parameters ======================%
        SE = strel('disk',1);
        img_dilated = imdilate(img_binary,SE);
        img_edge = img_dilated - img_binary;
        % img_edge = edge(img_binary,'sobel'); % currently causes an error

        [row, col] = find(imcrop(Aggs0(jj).binary, Aggs0(jj).rect));
        Aggs0(jj).length = max((max(row)-min(row)),(max(col)-min(col)))*pixsize(ii);
        Aggs0(jj).width = min((max(row)-min(row)),(max(col)-min(col)))*pixsize(ii);
        Aggs0(jj).aspect_ratio = Aggs0(jj).length/Aggs0(jj).width;

        %{
        [Aggs(aa).length, Aggs(aa).width] = ...
            agg.agg_dimension(img_edge,pixsize(ii));
            % calculate aggregate length and width
        Aggs(aa).aspect_ratio = Aggs(aa).length/Aggs(aa).width;
        %}

        Aggs0(jj).num_pixels = nnz(img_binary); % number of non-zero pixels
        Aggs0(jj).da = ((Aggs0(jj).num_pixels/pi)^.5)*2*pixsize(ii);
            % area-equialent diameter [nm]
        Aggs0(jj).area = nnz(img_binary).*pixsize(ii)^2;
            % aggregate area [nm^2]
        Aggs0(jj).Rg = gyration(img_binary,pixsize(ii));
            % calculate radius of gyration [nm]

        Aggs0(jj).perimeter = sum(sum(img_edge~=0))*pixsize(ii);
            % calculate aggregate perimeter
        % Aggs(ll).perimeter = ...
        %     agg.perimeter_length(img_binary,...
        %     pixsize(ii),Aggs(ll).num_pixels); % alternate perimeter

        [x,y] = find(img_binary ~= 0);
        Aggs0(jj).center_mass = [mean(x); mean(y)];

        if f_plot==1; tools.imshow_agg(Aggs0, ii, 0); drawnow; end
    end
    
    if f_plot==1; pause(0.1); end % pause very briefly to show overall aggregates
    
    Aggs = [Aggs, Aggs0]; % append current aggregate data
end

close(f0); % close figure showing progress

disp('Completed aggregate analysis.');
disp(' ');

end




%== GYRATION =============================================================%
%   Gyration calculates radius of gyration by assuming every pixel as an area
%   of pixsize^2
%   Author: Ramin Dastanpour
%-------------------------------------------------------------------------%
% Output:
%   Rg      Radius of gyration [nm]
%-------------------------------------------------------------------------%
function [Rg] = gyration(img_binary,pixsize)


total_area = nnz(img_binary)*pixsize^2;

[xpos,ypos] = find(img_binary);
n_pix = size(xpos,1);
Centroid.x = sum(xpos)/n_pix;
Centroid.y = sum(ypos)/n_pix;

Ar2 = zeros(n_pix,1);

for kk = 1:n_pix
    Ar2(kk,1) = (((xpos(kk,1)-Centroid.x)*pixsize)^2+...
        ((ypos(kk,1)-Centroid.y)*pixsize)^2)*pixsize^2;
end

Rg = (sum(Ar2)/total_area)^0.5;

end




%== AUTOCROP =============================================================%
%   Automatically crops an image based on binary information
%   Author:  Yeshun (Samuel) Ma, Timothy Sipkens, 2019-07-23
function [img_cropped,img_binary,rect] = autocrop(img_orig, img_binary)

[x,y] = find(img_binary);

space = 25;
size_img = size(img_orig);

% Find coordinates of top and bottom of aggregate
x_top = min(max(x)+space,size_img(1)); 
x_bottom = max(min(x)-space,1);
y_top = min(max(y)+space,size_img(2)); 
y_bottom = max(min(y)-space,1);


img_binary = img_binary(x_bottom:x_top,y_bottom:y_top);
img_cropped = img_orig(x_bottom:x_top,y_bottom:y_top);
rect = [y_bottom,x_bottom,(y_top-y_bottom),(x_top-x_bottom)];

end


