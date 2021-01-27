
% AGG2DPS  Compute statistics for primary particle size.
% This loops through .
% Author: Timothy Sipkens, 2020-12-02
% 
% INPUT:
%   Aggs    Aggregate structure
% 
% OUTPUT:
%   out     Data structure with fields for the various primary 
%           particle sizing technqiues. Generally, this includes 
%           the goemetric mean and standard deviation across the
%           range of aggregates. 
%=========================================================================%

function [out] = agg2dps(Aggs)


agg_fields = fields(Aggs);  % get the list of field names
idx_dp0 = find(or(contains(agg_fields, 'dp'), ...
    contains(agg_fields, 'sg')));  % get dp-containing fields

for ii=(idx_dp0')  % loop through dp-containing fields
    agg_field = agg_fields{ii};  % current field name
    
    % Skip 'dp' field (too generic).
    if strcmp(agg_field, 'dp'); continue; end
    
    % Deal with special kinds of fields.
    if contains(agg_field, 'edm_tot')  % this field has only one entry
        out.edm_tot = Aggs.dp_edm_tot;
        out.edm_tot_sg = Aggs.sg_edm_tot;
        continue;
        
    elseif contains(agg_field, 'sg')  % this is already a geostd., store as '*_sg2'
        out.([agg_field(4:end), '_sg2']) = Aggs.(agg_field);
        continue;
    end
    
    % Calculate the geometric mean diameter.
    out.(agg_field(4:end)) = exp(nanmean(log([Aggs.(agg_field)])));
    % out.(agg_field(4:end)) = nanmedian([Aggs.(agg_field)]);
    
    % Compute geometric standard deviation.
    out.([agg_field(4:end), '_sg']) = ...
        exp(nanstd(log([Aggs.(agg_field)])));
end


end
