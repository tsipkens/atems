
% TEXTDONE  Appends an orange "DONE" to end of a line.
%  
%  AUTHOR: Timothy Sipkens, 2021-03-30

function [] = textdone(n)

% Number of trailing new line characters. 
% Default is n = 1.
if ~exist('n', 'var'); n = []; end
if isempty(n); n = 1; end

fprintf([char(8), ' [', 8, '< <strong>DONE</strong>]', 8, ...
    repmat('\n', [1, n])]);  % number of line breaks after DONE

end

