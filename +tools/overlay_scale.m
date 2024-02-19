
% OVERLAY_SCALE  Overlay scale bar on current image. 
%  
%  AUTHOR: Timothy Sipkens, 2024-02-19

function overlay_scale(pixsize, frac)

if ~exist('frac', 'var'); frac = []; end
if isempty(frac); frac = 0.2; end  % scale bar is roughly 20% of width

I = getimage(gca);

bar_length0 = floor((size(I, 2) .* frac));  % in pixels

bar_length1 = round(pixsize * bar_length0);  % in nm

%-{
% If above 5x, then round up to nearest 1xx.
s1 = num2str(bar_length1);  % convert to string for analysis
b1 = str2double(s1(1));  % first digit
l1 = length(s1);  % length of number
if b1 > 5
    if b1 > 7; bar_length1 = 10 ^ l1;
    else; bar_length1 = 5 * 10 ^ (l1 - 1);
    end
end
%}

bar_length1 = round(bar_length1, 1, 'significant');  % round in nm
bar_length = bar_length1 / pixsize;  % in pixels

% Properties for scale bar.
margin = floor((size(I) .* 0.05));
bar_height = max(margin(2) / 7, 1);
font_specs = {'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'Bottom', ...
    'FontSize', 11, 'FontWeight', 'bold'};   % properties of text label

hold on;
rectangle('Position', ...
    [size(I,1) - margin(1) - bar_length, ...
     size(I,2) - margin(2), ...
     bar_length, bar_height], ...
     'FaceColor', [0 0 0], ...
     'Curvature', 0.5);


if bar_length1 > 1e3  % then use micron
    text(size(I,1) - margin(1), size(I,2) - margin(2) - bar_height/5, ...
        [num2str(bar_length1 ./ 1e3), ' um'], ...
        font_specs{:});
else
    text(size(I,1) - margin(1), size(I,2) - margin(2) - bar_height/5, ...
        [num2str(bar_length1), ' nm'], ...
        font_specs{:});
end
hold off;

end
