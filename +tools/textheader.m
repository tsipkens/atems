
% TEXTHEADER  A simple utility to format text headers/footers for console.
% Author: Timothy Sipkens, 2020-11-11
%=========================================================================%

function [] = textheader(txt, f_before)

% Parse inputs.
if ~exist('f_before', 'var'); f_before = []; end
if isempty(f_before); f_before = 1; end  % assume header

if ~exist('txt', 'var'); txt = []; end  % if no text, instead format footer
if isempty(txt); f_before = 0; txt = 'Complete.'; end


dots = ''; % will hold text to display "..." if before
if f_before
    fprintf('\n');
    dots = '...';
end


fprintf(['[ <strong>', upper(txt), dots, '</strong> ]\n']);


if ~f_before; fprintf('\n\n'); end

end

