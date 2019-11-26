

function [] = write_excel(fname,Aggs)

Aggs_fields = fields(Aggs); % get field names

for ii=1:length(Aggs_fields)
    bool1 = isa(Aggs(1).(Aggs_fields{ii}),'char');
        % keep field if field is a string
        
    bool3 = and(isa(Aggs(1).(Aggs_fields{ii}),'double'),...
        all(size(Aggs(1).(Aggs_fields{ii}))<=2));
            % keep field if the field is a double, with a small size
    
    if ~or(bool1,bool3) % remove unwanted fields
        Aggs = rmfield(Aggs,Aggs_fields{ii});
    end
end

t0 = struct2table(Aggs);
writetable(t0,fname);

end


