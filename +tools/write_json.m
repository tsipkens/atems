

function [t2,t0] = write_json(var,fname)

fid = fopen(fname,'wt'); % open file, overwriting previous text


%-- Encode json ----------------------------------------------------------%
t0 = jsonencode(var); % generate json text using built-in function


%-- Format parameters ----------------------------------------------------%
%   Includes adding tabs and spaces to improve human readability.
t0 = strrep(t0,':',': '); % add space after all colons

tabs = ''; % variable to add tabbed space for different levels (start at zero)
linestart = 1; % start of the next/current line of text (start at first character)
linelength = 70; % add a line break after a comma in an array if the line
                 % length exceeds this value
inarray = 0; % determine whether the current characters are in array


%-- Loop through characters, looking for key characters ------------------%
ii = 1;
while ii<=length(t0) % loop through characters in json string
    switch t0(ii)
        case {'[','{'}
            %-- Check if the next character should be on the same line ---%
            if ii~=length(t0) % check if '[{' and modify
                if strcmp(t0(ii+1),'{')
                    ii=ii+1; % skip a character
                end
            end
            
            %-- Check if in an array -------------------------------------%
            %   Preserve formatting for arrays in arrays
            if strcmp(t0(ii),'[')
                if inarray; ii=ii+1; continue; end
            end
            
            [linestart,tabs,inarray] = ...
                start_bracket(fid,t0,ii,linestart,tabs);
            
            %-- Check if entering array ----------------------------------%
            if ii~=length(t0) % if entering an array, turn inarray variable on
                if and(strcmp(t0(ii),'['),strcmp(t0(ii+1),'['))
                    inarray = 2;
                elseif and(strcmp(t0(ii),'['),~strcmp(t0(ii+1),'{'))
                    inarray = 1;
                end
            end
        
        case {'}',']'}
            %-- Check if in an array -------------------------------------%
            %   Preserve formatting for arrays in arrays
            if or(and(inarray==2,strcmp(t0(ii+1),']')),inarray==1)
                inarray = 0;
                ii=ii+1;
            end
            if and(strcmp(t0(ii),']'),inarray==2)
                ii=ii+1;
                continue;
            end
            
            %-- Check if previous line was written -----------------------%
            if ((ii-1)-linestart)>0
                fprintf(fid,[tabs,t0(linestart:(ii-1)),'\n']);
                linestart = ii;
            end
            
            %-- Check if the next character should be on the same line ---%
            if ii~=length(t0) % check if '[{' and modify
                if or(strcmp(t0(ii+1),']'),strcmp(t0(ii+1),','))
                    ii=ii+1; % skip a character
                end
            end
            
            tabs = tabs(1:(end-2));
            fprintf(fid,[tabs,t0(linestart:ii),'\n']); % output bracket
            linestart = ii+1; % start new line at next character
            inarray = 0;
        
        case ','
            %-- Check if line break should be placed after the comma -----%
            if any([inarray==0,...
                and((ii-linestart)>(linelength-2*length(tabs)),inarray==1),...
                all([(ii-linestart)>(linelength-2*length(tabs)),inarray==2,strcmp(t0(ii+1),'[')])])
                    % only break around commas is not in an array or the line
                    % exceeds the linelength variable
                fprintf(fid,[tabs,t0(linestart:ii),'\n']);
                linestart = ii+1; % start new line at next character
            end
    end
    
    ii = ii+1; % increment counter
end

fclose(fid); % close file


%-- Test if json can be read in properly ---------------------------------%
t10 = fileread(fname);
t2 = jsondecode(t10);


end


function [linestart,tabs,inarray] = start_bracket(fid,str,ii,linestart,tabs)

fprintf(fid,[tabs,str(linestart:ii),'\n']); % output bracket + any previous text
tabs = [tabs,'  ']; % increase tab level
linestart = ii+1; % start new line at next character
inarray = 0; % by default, exit array

end


