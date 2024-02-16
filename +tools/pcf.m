
% PCF  Compute the pair correlation function(PCF) for a binary image. 
%  
%  AUTHOR: Timothy Sipkens, 2023-12-13

function [g, v] = pcf(img_binary, v, ns)

if ~exist('v', 'var'); v = []; end

if ~exist('ns', 'var'); ns = []; end
if isempty(ns); ns = 1e5; end


% Vector of distances.
if or(isempty(v), numel(v) == 1)
    
    if numel(v) == 1  % then radius of gyration (in px) or similar, use to generate v
        R = v;
        maxd = R * 2 * 2;
    else  % otherwise, use size of the image
        maxd = min(size(img_binary)) / 4;
    end

    % v = linspace(1, maxd, 50)';
    v = [logspace(0, log10(maxd), 50)]';
end


[row, col] = find(img_binary); % starting row/col in aggregate
g = zeros(size(v));

for ii=1:length(v)
    
    ri = randi(length(row), [ns,1]); % get random entries

    rthe = 2*pi .* rand([ns,1]);  % random angle
    rx = round(v(ii) .* sin(rthe));  % random x dir.
    ry = round(v(ii) .* cos(rthe));  % random y dir.
    
    row_new = row(ri) + ry; % new row
    col_new = col(ri) + rx;  % new col
    
    % Catch out-of-bounds cases.
    out_of_bounds = or( ...
        or(row_new < 1, row_new > size(img_binary,1)), ... 
        or(col_new < 1, col_new > size(img_binary,2)));
    nout = sum(out_of_bounds);
    row_new(out_of_bounds) = [];
    col_new(out_of_bounds) = [];
    
    % Get new pixels. 
    in = img_binary(sub2ind(size(img_binary), row_new, col_new));

    % Pad with removed cases. 
    g(ii) = sum(in) ./ (length(in) + nout);

end

%{
% Diagnostic plotting.
if exist('R', 'var')
    plot(v ./ R, g);
    xlabel('Pixel distance / R [px/px]');
else
    plot(v, g);
    xlabel('Pixel distance [px]');
end
set(gca, 'XScale', 'log');
%}

end
