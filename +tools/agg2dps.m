
% AGG2DPS  Compute statistics about primary particle size for an aggregate structure.
% Author: Timothy Sipkens, 2020-12-02
%=========================================================================%

function [out] = agg2dps(Aggs)


agg_fields = fields(Aggs);
idx_dp0 = find(or(contains(agg_fields, 'dp'), contains(agg_fields, 'sg')));

for ii=(idx_dp0')
    agg_field = agg_fields{ii};  % current field name
    
    % Skip 'dp' field (too generic).
    if strcmp(agg_field, 'dp'); continue; end
    
    
    
    if contains(agg_field, 'edm_tot')  % this field has only one entry
        out.edm_tot = Aggs.dp_edm_tot;
        out.edm_tot_sg = Aggs.sg_edm_tot;
        continue;
        
    elseif contains(agg_field, 'sg')  % this is already a geostd., store as '*_sg2'
        out.([agg_field(4:end), '_sg2']) = Aggs.(agg_field);
        continue;
    end
    
    % Calculate the median.
    out.(agg_field(4:end)) = nanmedian([Aggs.(agg_field)]);

    % Compute geometric standard deviation.
    out.([agg_field(4:end), '_sg']) = ...
        exp(nanstd(log([Aggs.(agg_field)])));
end


end
