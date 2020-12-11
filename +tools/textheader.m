
% TEXTHEADER  A simple utility to format text headers/footers for console.
% Author: Timothy Sipkens, 2020-11-11
%=========================================================================%

function [] = textheader(txt, f_before)

% Parse inputs.
if ~exist('f_before', 'var'); f_before = []; end
if isempty(f_before); f_before = 1; end  % assume header

if ~exist('txt', 'var'); txt = []; end  % if no text, instead format footer
if isempty(txt); f_before = 0; txt = 'Complete'; end


fprintf(['\n[ <strong>', upper(txt), '</strong> ]\n']);


if ~f_before; fprintf('\n\n\n');
else; fprintf('\n'); end

end

