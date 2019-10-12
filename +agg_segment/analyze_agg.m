
% ANALYZE_AGG Analyze the binary mask to determine aggregate properties (e.g. Rg)
% Author:     Timothy Sipkens
%=========================================================================%

function [Aggs] = analyze_agg(img_binary,img,pixsize)

disp('Calculating aggregate areas...');
CC = bwconncomp(abs(img_binary-1)); % find seperate aggregates
naggs = CC.NumObjects; % count number of aggregates
Aggs(naggs).fname = ''; % pre-allocate new space for aggregates



%== Main loop to analyze each aggregate ==============================%
figure(gcf);
tools.plot_binary_overlay(img,img_binary);
for jj = 1:naggs % loop through number of found aggregates
    
    Aggs(jj).pixsize = pixsize;
    Aggs(jj).id = jj;
    
    Aggs(jj).image = img;
        % store image that the aggregate occurs in
    
    %-- Step 3-2: Prepare an image of the isolated aggregate ---------%
    img_binary = zeros(size(img_binary));
    img_binary(CC.PixelIdxList{1,jj}) = 1;
    Aggs(jj).binary = img_binary;
    
    [Aggs(jj).img_cropped,Aggs(jj).img_cropped_binary,Aggs(jj).rect] = ...
        agg_segment.autocrop(img,img_binary);
    
    
    %== Compute aggregate dimensions/parameters ======================%
    SE = strel('disk',1);
    img_dilated = imdilate(img_binary,SE);
    img_edge = img_dilated-img_binary;
    % img_edge = edge(img_binary,'sobel'); % currently causes an error
    
    [row, col] = find(Aggs(jj).img_cropped_binary);
    Aggs(jj).length = max((max(row)-min(row)),(max(col)-min(col)))*pixsize;
    Aggs(jj).width = min((max(row)-min(row)),(max(col)-min(col)))*pixsize;
    Aggs(jj).aspect_ratio = Aggs(jj).length/Aggs(jj).width;
    
    %{
    [Aggs(aa).length, Aggs(aa).width] = ...
        agg_segment.agg_dimension(img_edge,pixsize);
        % calculate aggregate length and width
    Aggs(aa).aspect_ratio = Aggs(aa).length/Aggs(aa).width;
    %}
    
    Aggs(jj).num_pixels = nnz(img_binary); % number of non-zero pixels
    Aggs(jj).da = ((Aggs(jj).num_pixels/pi)^.5)*2*pixsize; % area-equialent diameter
    Aggs(jj).area = nnz(img_binary).*pixsize^2; % aggregate area
    Aggs(jj).Rg = ...
        agg_segment.gyration(img_binary,pixsize);
        % calculate radius of gyration
    
    Aggs(jj).perimeter = sum(sum(img_edge~=0))*pixsize;
        % calculate aggregate perimeter
    % Aggs(ll).perimeter = ...
    %     agg_segment.perimeter_length(img_binary,...
    %     pixsize,Aggs(ll).num_pixels); % alternate perimeter
    
    [x,y] = find(img_binary ~= 0);
    Aggs(jj).center_mass = [mean(x); mean(y)];
    
    figure(gcf);
    tools.plot_aggregates(Aggs,[],jj,0);
end

% saveas(gcf,['..\images-processed\',Aggs(aa).fname(1:end-4),'.jpg']);

disp('Completed aggregate analysis.');
disp(' ');
pause(1);

end

