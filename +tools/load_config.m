
% LOAD_CONFIG  Loads settings from configuration file (YML, YAML, or JSON). 
%  
%  Files are loaded in order supplied, overwriting properties where
%  relevant. 
%  
%  AUTHOR: Timothy Sipkens, 2021-03-25

function prop = load_config(fnames, prop)

if ~iscell(fnames); fnames = {fnames}; end

if ~exist('prop', 'var'); prop = []; end
if isempty(prop); prop = struct(); end

for ii=1:length(fnames)
    
    prop0 = read_json(fnames{ii});  % read new settings
    
    
    f = fieldnames(prop0);
    
    % Copy (or overwrite) existing settings.
    for jj = 1:length(f)
        
        % Attempt to interpret Matlab expressions.
        prop0.(f{jj}) = interpret(prop0.(f{jj}));
        
        % Overwrite existing configuration.
        prop.(f{jj}) = prop0.(f{jj});
    end
    
end

end



% INTERPRET  Attempt to interpret Matlab expressions.
function e0 = interpret(f)

if isa(f, 'char')
    [e0, success] = str2num(f);
    if success; return; end

    try  % try 'eval(...)'
        e0 = eval(f);
    catch
        e0 = f;
        return;  % just continue
    end
else
    e0 = f;
end

end




% READ_JSON  Read JSON structured configuration files. 
%  Allows for C++ or Javscript style commenting.
%  
%  AUTHOR: Timothy Sipkens, 2021-04-20

function results = read_json(file)

fid = fopen(file);
raw = fread(fid, inf);  % raw file contents
str = char(raw');  % transform to char
fclose(fid);

% Remove comments.
str = erase(erase(eraseBetween( ...
    erase(eraseBetween(str, "//", newline), "//"), ...
    "/*", "*/"), "/*"), "*/");

results = jsondecode(str);

end



