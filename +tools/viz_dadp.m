
% VIZ_DADP  Generate a formatted plot of da versus dp. 
% This includes a fit relation and the universal relation of Olfert and Rogak.
% Author: Timothy Sipkens
%=========================================================================%

function [h, a1] = viz_dadp(Aggs_da, dp, cm)

% Parse inputs
if isstruct(Aggs_da); da = [Aggs_da.da]; dp = [Aggs_da.dp];
else; da = Aggs_da; end

if ~exist('cm', 'var'); cm = []; end
if isempty(cm); cm = [0.12,0.59,0.96]; end



% In case some dp failed and are NaN, remove entries. 
idx_remove = find(isnan(dp));
da(idx_remove) = [];
dp(idx_remove) = [];


% Plot data
loglog(da, dp, '.', 'Color', cm);
hold on;


% Get current figure limits
xlims = xlim; ylims = ylim;
t0 = min([xlims(1),ylims(1)]);
t1 = max([xlims(2),ylims(2)]);


% Plot dp-da relation
p1 = polyfit(log10(da), log10(dp),1);
p1_val = 10 .^ polyval(p1, log10(xlims));
a1 = [10^p1(2), p1(1)];
loglog(xlims, p1_val, 'Color', cm);


% Plot universal relation from Olfert and Rogak
loglog(xlims, 10.^(log10(17.8) + 0.35.*log10(xlims./100)), 'k--');


%-- Plot 2-sigma ellipse -------------------------------------------------%
mu = [mean(log10(da)), mean(log10(dp))]; % mean for ellipse center
Sigma = cov(log10(da), log10(dp)); % covariance of plotting ellipse

[V, D] = eig(Sigma.*2);
t = linspace(0, 2*pi); % points around the edge of the circle
a = (V*sqrt(D)) * [cos(t(:))'; sin(t(:))']; % points on the ellipse

loglog(10.^(a(1, :)+mu(1)), 10.^(a(2, :)+mu(2)), '--', ...
    'Color', cm);
%-------------------------------------------------------------------------%


% Plot polygon of off-limit particles (i.e., where da > dp)
% Edge of this region corresponds to single primary particle aggregates.
fill([xlims(1), xlims(1), ylims(2)], ...
    [xlims(1), ylims(2), ylims(2)], ...
    [0.95,0.95,0.95], 'EdgeColor', [0.5,0.5,0.5]);


% Rearrange order, so shaded region is in background
h = get(gca, 'Children');
set(gca, 'Children', [h(2:end); h(1)]);

xlabel('d_a [nm]');
ylabel('d_p [nm]');
legend({'d_p > d_a', 'Data', ...
    ['Power law fit (',num2str(a1(1),3),'d_a^{',num2str(a1(2),2),'})'], ...
    'Universal relation', '2-sigma ellipse'}, ...
    'Location', 'southeast');


hold off;
if nargout==0; clear h; end % remove output if none requested

end

