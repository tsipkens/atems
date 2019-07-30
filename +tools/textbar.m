
function textbar(pct,opt_backspace)
% TEXTBAR           Print out a text-based progress bar.
% Original author:  Samuel Grauer, 2017-11-16
% Modified by:      Timothy Sipkens, 2018-11-26
%
%-------------------------------------------------------------------------%
% Input:
%   pct     Progress complete, as a fraction
%-------------------------------------------------------------------------%


%--- Initialization ------------------------------------------------------%
%-- Parameters ----%
n_dot = 40;
n_str = n_dot+17;

%-- Parse input ----%
if ~exist('pct','var')
    pct = 0;
elseif isempty(pct) || pct < 0
    pct = 0;
elseif pct > 1
    pct = 1;
end

%-- Parse input ----%
if ~exist('opt_backspace','var')
    opt_backspace = 1;
elseif isempty(opt_backspace)
    opt_backspace = 1;
end
%-------------------------------------------------------------------------%


%--- Print progress ------------------------------------------------------%
if pct == 0
    str_back = '';
    str_out = ['  [',repmat(' ',[1 n_dot]),'] 0%%'];
else
    if opt_backspace
        str_back = repmat(char(8),[1 n_str]);
    else
        str_back = '';
    end
    nc = ceil(pct*n_dot);
    
    str_p01 = repmat('-',[1 nc]);
    str_p02 = repmat(' ',[1 n_dot-nc]);
    
    str_out = ['  [',str_p01,str_p02,'] ',num2str(100*pct,'%.0f'),'%%'];
end

fprintf([str_back,str_out,repmat(' ',[1 n_str-length(str_out)]),'\n']);
%-------------------------------------------------------------------------%

end


