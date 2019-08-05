
% EVALUATE      Runs manual primary particle sizing on an array of aggregates.
% Modified by:  Timothy Sipkens, 2019-07-23

% Note:
%   Originally written by Ramin Dastanpour, Steve Rogak, Hugo Tjong,
%   Arka Soewono from the University of British Columbia, 
%   Vanouver, BC, Canada
%=========================================================================%

function [Aggs,Data] = evaluate(Aggs,bool_plot)

%-- Parse inputs and load image ------------------------------------------%
if ~exist('bool_plot','var'); bool_plot = []; end
if isempty(bool_plot); bool_plot = 0; end


%== Process image ========================================================%
for ll = 1:length(Aggs) % run loop as many times as images selected
    
    Data = struct; % re-initialize data structure
    
    pixsize = Aggs(ll).pixsize; % copy pixel size locally
    img_cropped = Aggs(ll).image;
    img_binary = Aggs(ll).binary;
    
    %== Step 3: Analyzing each aggregate =================================%
    bool_finished = 0;
    jj = 0; % intialize particle counter
    img_cropped2 = imcrop(img_cropped);
    % t0 = 0.6.*(img_cropped.*uint8(img_binary));
    % imshow(0.4.*img_cropped+t0);
    imshow(img_cropped2);
    hold on;
    
    while bool_finished == 0

        jj = jj+1;
        
        uiwait(msgbox('Please select two points on the image that correspond to the length of the primary particle',...
        ['Process Stage: Length of primary particle ' num2str(jj)...
        '/' num2str(jj)],'help'));

        [x,y] = ginput(2);
        
        Data.length(jj,1) = pixsize*sqrt((x(2)-x(1))^2+(y(2) - y(1))^2);
        line ([x(1),x(2)],[y(1),y(2)], 'linewidth', 3);
        
        [a,b] = ginput(2);
        
        Data.width(jj,1) = pixsize*sqrt((a(2)-a(1))^2+(b(2) - b(1))^2);
        line ([a(1),a(2)],[b(1),b(2)],'Color', 'r', 'linewidth', 3);
        
        %-- Save center of the primary particle --------------------------%
        Data.centers(jj,:) = manual.find_centers(x,y,a,b);
        Data.radii(jj,:) = (sqrt((a(2)-a(1))^2+(b(2)-b(1))^2)+...
        	sqrt((x(2)-x(1))^2+(y(2)-y(1))^2))/4;
            % takes an average over drawn lines
        
        %-- Check if there are more primary particles --------------------%
        choice = questdlg('Do you want to analyze another primary particle ?',...
        'Continue?','Yes','No','Yes');
        if strcmp(choice,'Yes')
        	bool_finished = 0;
        else
        	bool_finished = 1;
        end
        
    end
    
    Data = tools.refine_circles(img_cropped,Data);
        % allow for refinement of circles
    
    %== Save results =====================================================%
    %   Format output and autobackup data ------------------------%
    Aggs(ll).manual = Data; % copy Dp data structure into img_data
    save('manual_data.mat','Aggs'); % backup img_data
    
    close all;

end

Data = [Aggs.manual];

end

