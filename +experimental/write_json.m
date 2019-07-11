
var = data;
fname = 'sample2.json';
fid = fopen(fname,'wt');

%-- Encode json ----------------------------------------------------------%
t0 = jsonencode(var);


%-- Format json ----------------------------------------------------------%
tabs = '';
linestart = 1;
linelength = 70;
inarray = 0;
ii = 1;
while ii<=length(t0)
    if strcmp(t0(ii:ii+1),'[{')
        fprintf(fid,[tabs,t0(ii:(ii+1)),'\r']);
        tabs = [tabs,'\t']; % add tab
        ii = ii+1; % skip a character
        linestart = ii+1;
        inarray = 0;
    
    elseif strcmp(t0(ii),'[')
        fprintf(fid,[tabs,t0(linestart:ii),'\r']);
        tabs = [tabs,'\t']; % add tab
        linestart = ii+1;
        inarray = 1;
        
    elseif strcmp(t0(ii),'{')
        fprintf(fid,[tabs,t0(linestart:ii),'\r']);
        tabs = [tabs,'\t']; % add tab
        linestart = ii+1;
        inarray = 0;
        
    elseif strcmp(t0(ii:ii+1),'}]')
        if ((ii-1)-linestart)>0 % if previous line was not written
            fprintf(fid,[tabs,t0(linestart:(ii-1)),'\r']);
        end
        tabs = tabs(1:(end-2)); % remove tab
        fprintf(fid,[tabs,t0(ii:(ii+1)),'\r']);
        ii = ii+1; % skip a character
        linestart = ii+1;
        inarray = 0;
        
    elseif strcmp(t0(ii:ii+1),'],')
        if ((ii-1)-linestart)>0 % if previous line was not written
            fprintf(fid,[tabs,t0(linestart:(ii-1)),'\r']);
        end
        tabs = tabs(1:(end-2)); % remove tab
        fprintf(fid,[tabs,t0(ii:(ii+1)),'\r']);
        ii = ii+1; % skip a character
        linestart = ii+1;
        inarray = 0;
        
    elseif strcmp(t0(ii:ii+1),'},')
        if ((ii-1)-linestart)>0 % if previous line was not written
            fprintf(fid,[tabs,t0(linestart:(ii-1)),'\r']);
        end
        tabs = tabs(1:(end-2)); % remove tab
        fprintf(fid,[tabs,t0(ii:(ii+1)),'\r']);
        ii = ii+1; % skip a character
        linestart = ii+1;
        
    elseif strcmp(t0(ii),']')
        if ((ii-1)-linestart)>0 % if previous line was not written
            fprintf(fid,[tabs,t0(linestart:(ii-1)),'\r']);
        end
        tabs = tabs(1:(end-2)); % remove tab
        fprintf(fid,[tabs,t0(ii),'\r']);
        linestart = ii+1;
        inarray = 0;
        
    elseif strcmp(t0(ii),'}')
        if ((ii-1)-linestart)>0 % if previous line was not written
            fprintf(fid,[tabs,t0(linestart:(ii-1)),'\r']);
        end
        tabs = tabs(1:(end-2)); % remove tab
        fprintf(fid,[tabs,t0(ii),'\r']);
        linestart = ii+1;
        inarray = 0;
        
    elseif strcmp(t0(ii),',')
        if or(~inarray,(ii-linestart)>(linelength-2*length(tabs)))
            fprintf(fid,[tabs,t0(linestart:ii),'\r']);
            linestart = ii+1;
        end
    end
    
    ii = ii+1;
end

% t1 = strrep(t0,'[{',new);

fclose(fid);

t10 = fileread(fname);
t2 = jsondecode(t10);


