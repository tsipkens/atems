
% WRITE_EXCEL Write aggregate data to an Excel file.
% Author: Timothy Sipkens, 2019-11-26
%=========================================================================%

function [] = write_excel(Aggs, fname)

disp('Writing aggregate data to an Excel file...');

folder = fileparts(fname); % get folder name
if ~isfolder(folder) % check if folder exists
   mkdir(folder); % create the folder if it does not exist
end

Aggs_fields = fields(Aggs); % get field names

for ii=1:length(Aggs_fields)
    bool1 = isa(Aggs(1).(Aggs_fields{ii}), 'char');
        % keep field if field is a string
        
    bool3 = and(isa(Aggs(1).(Aggs_fields{ii}), 'double'),...
        all(size(Aggs(1).(Aggs_fields{ii})) <= 2));
            % keep field if the field is a double, with a small size
    
    if ~or(bool1,bool3) % remove unwanted fields
        Aggs = rmfield(Aggs, Aggs_fields{ii});
    end
end

t0 = struct2table(Aggs, 'AsArray', true);
writetable(t0, fname);

disp('Complete.');
disp(' ');

end


