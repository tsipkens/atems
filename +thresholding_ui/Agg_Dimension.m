%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [ A_length, A_width ] = Agg_Dimension(img_edge,pixsize)
%Aggregate_Dimension etermines the length & width of the agglomerate, and
%provides a rotated image of the particle with length and width axis
%   Based on function_length_width3 (Arka and Hugo) with memory saving improvement
%   ---LENGTH---
%   ---ALGORITHM---
%   Given the agglomerate's fourth edge image, E4, the algorithm finds the 
%   y and x indices of the white pixels (value = 1) in the arrays of ROW and 
%   COL, respectively. Then, it computes the euclidean distance between every 
%   single white pixel with reference to every other white pixel, and
%   selects the greatest distance, which yields the length of the
%   agglomerate.  It is important to note that for speed, the distances are
%   computed in a vectorized form, such that each 'DISTANCE' array represents
%   the distances of the considered white pixel with reference to all other
%   pixels.  The maximum of the 'DISTANCE' array is chosen as the
%   'greatest_distance', and then compared to the length.  Once the length is
%   found, the position of the two pixels is recorded via x1_l_bot, etc...
%
%   ---WIDTH---
%   ---ALGORITHM---
%   this algorithm calculates the width by rotating the image by 'theta' degrees
%   counterclockwise, until the length axis is parallel with the y-axis.
%   Then the width corresponds to the location of the greatest x indices of a
%   white pixel minus the location of the smallest x indices of a white pixel.

[ROW1, COL1] = find (img_edge);
area_edge_particle = nnz(img_edge);
length = 0;

%== Length calculation ===================================================%
%   To compute the length in vector form, and record the position of the two
%   pixels that specify the length.  Since the 'find' function searches
%   column-by-column, in the order of increasing x, then increasing y, the
%   pixel specified by 'pos1' will always have a greater y-indices than the
%   pixel specified by pos2.  This helps determine theta, later on in the
%   program.

for pos1 = 1:1:area_edge_particle
    DISTANCE = ( (COL1 - COL1(pos1)).^2 + (ROW1 - ROW1(pos1)).^2 ).^.5;
    [greatest_distance, pos2] = max(DISTANCE);
    if greatest_distance >= length
        length = greatest_distance;
        x1_l_bot = COL1(pos1);
        y1_l_bot = ROW1(pos1);
        x2_l_top = COL1(pos2);
        y2_l_top = ROW1(pos2);
    end
end
A_length=length*pixsize;
clear COL1 ROW1 DISTANCE area_edge_particle


%== Width Calculation ====================================================%
%   Tto mark the pixels that specify the length.  It is important to note that
%   an error may arise during the rotation of the image, because some pixels
%   are obscured, or even deleted via the rotation process.  In order to
%   prevent this, the pixel left-adjacent to the true length-defining pixels
%   are also marked with a value of '2', or '3'.

Temp_Final_Edge = img_edge;
Temp_Final_Edge (y1_l_bot, x1_l_bot:(x1_l_bot+2)) = 2;
Temp_Final_Edge (y1_l_bot, x1_l_bot+1) = 2;
Temp_Final_Edge (y2_l_top, x2_l_top) = 3;
Temp_Final_Edge (y2_l_top, x2_l_top+1) = 3;

% to determine theta, the problem becomes a system of 2 equations with 2
% unknown, with 2 differing situations.
if x1_l_bot == x2_l_top
    theta = 0;
end
if x1_l_bot < x2_l_top
    theta = abs(atan( (x2_l_top - x1_l_bot) / (y1_l_bot - y2_l_top) ) * 180 / pi);
end
if x1_l_bot > x2_l_top
    theta = abs (180 - (atan( (x1_l_bot - x2_l_top) / (y1_l_bot - y2_l_top) ) * 180 / pi));
end


% to rotate the image counterclockwise, until the length axis is vertical
Rotated_Final_Edge = imrotate (Temp_Final_Edge, theta);


% to find the maximum and minimum x values to calculate the width
[ROW2, COL2] = find (Rotated_Final_Edge > 0);
[x1_w_rit, i]  = max(COL2);
y1_w_rit = ROW2(i);
[x2_w_lef, i] = min(COL2);
y2_w_lef = ROW2(i);    
    
width = x1_w_rit - x2_w_lef;

A_width=width*pixsize;


%-- PLOT LENGTH AND WIDTH AXIS ALONG ROT ---------------------------------%
% ---ALGORITHM---
% To draw the perpendicular length axis, the indices of the length-defining
% pixels are needed.  These are located by finding the pixels that were 
% originally marked with values of '2' and '3'.  However, due to the fact 
% that during rotation, some pixels are lost, it may be better to find the
% maximum and minimum y values instead.

[ROW3, COL3] = find (Rotated_Final_Edge == 2);
if Rotated_Final_Edge (ROW3(1), COL3(1)) == 2
    x1_l_bot_rot = COL3(1);
    y1_l_bot_rot = ROW3(1);
end

[ROW4, COL4] = find (Rotated_Final_Edge == 3);
if Rotated_Final_Edge (ROW4(1), COL4(1)) == 3
    x2_l_top_rot = COL4(1);
    y2_l_top_rot = ROW4(1);
end

% to plot and save ROT with length and width, where the length is the blue vertical 
% line and the width is the red horizontal line.  Note that they are
% perpendicular.

% imshow(Rotated_Final_Edge)
% hold on
% line ([x1_l_bot_rot, x2_l_top_rot], [y1_l_bot_rot, y2_l_top_rot], 'linewidth', 3);
% line ([x1_w_rit, x2_w_lef], [y2_w_lef, y2_w_lef],'Color', 'r', 'linewidth', 3);
% line ([x1_w_rit, x1_w_rit], [y1_w_rit, y2_w_lef],'Color', 'r', 'linewidth', 3);

%{
cd(mainfolder)
cd('data/ManualOutput')
saveas(gcf,[FileName '_Aggregate_L_W_' num2str(particle_number) '.tif'])
close all
cd (mainfolder)
%}

end

