
% VIZ_KDENSITY  Generate kernsel density estimates from the data.
% Author: Timothy Sipkens, 2019-07-29
%=========================================================================%

function [h, x, y] = viz_kdensity(Aggs, field)

% Parse input
if ~exist('field', 'var'); field = 'da'; end

td = log10(vertcat(Aggs.(field))); % get aggregate properties
[y,x] = ksdensity(td, 'Bandwidth', 0.15); % apply ksdensity for distribution
h = semilogx(10.^x, y); % plot results

% Add axis labels
xlabel(field);
ylabel(['p(', field, ')']);

if nargout==0; clear h; end

end
