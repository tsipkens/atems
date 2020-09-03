
% VIZ_DARHO  Generate a formatted plot of da versus effective density. 
% This includes a fit relation and the universal relation of Olfert and Rogak.
% Author: Timothy Sipkens
%=========================================================================%

function [] = viz_darho(Aggs_da, dp)

% Parse inputs
if isstruct(Aggs_da); da = [Aggs_da.da]; dp = [Aggs_da.dp];
else da = Aggs_da; end


% Evaluate effective density
ka = 1.13;
Dalpha = 1.1;
rho0 = 1800; % estimated material density (for soot)
rho = ka .* rho0 .* (dp./da) .^ (3 - 2.*Dalpha); % eff. density from relation


% Plot data
loglog(da, rho, '.', 'Color', [0.12,0.59,0.96]);
hold on;


% Get and adjust current figure limits
ylims = ylim; ylim([ylims(1), 2e3]);
xlims = xlim; ylims = ylim;
t0 = min([xlims(1),ylims(1)]);
t1 = max([xlims(2),ylims(2)]);


% Plot dp-da relation
p1 = polyfit(log10(da), log10(rho),1);
p1_val = 10 .^ polyval(p1, log10([t0,t1]));
loglog([t0,t1], p1_val, 'Color', [0.12,0.59,0.96]);


% Plot universal relation from Olfert and Rogak
rho_or = ka .* rho0 .* ( ...
    10.^(log10(17.8) + 0.35.*log10([t0,t1]./100)) ./ ...
    [t0,t1]) .^ (3 - 2.*Dalpha);
loglog([t0,t1], rho_or, 'k--');


% Plot material density of soot
plot(xlims, [1800, 1800], 'k');
hold off;


xlabel('d_a [nm]');
ylabel('{\rho}_{eff} [kg/m^3]');
legend({'Data', 'Power law fit', 'Universal relation', ...
    '{\rho} = 1800 kg/m^3'}, ...
    'Location', 'southwest');


if nargout==0; clear h; end % remove output if none requested

end

