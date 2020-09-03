
% POST_ELLIPSE  Plots an ellipse give a center, major and minor radii, and slope.
% Author: Timothy Sipkens, 2019-10-27
% Note:   For raidus, the first entry is the major axis, the second entry
%         is the minor axis
%=========================================================================%

function h = post_ellipse(mu, Sigma, s, cspec)

%-- Parse inputs ---------------------------------------------------------%
if ~exist('s','var'); s = []; end
if isempty(s); s = 1; end

if ~exist('cspec','var'); cspec = []; end
if isempty(cspec); cspec = 'k'; end
%-------------------------------------------------------------------------%


% Flip mean and covar.
mu = fliplr(mu);
Sigma = rot90(Sigma,2);

% Double number of std. dev. for ellipse
% (i.e., one std. dev. in each direction).
s = s.*2;

[V, D] = eig(Sigma.*s);

t = linspace(0, 2*pi);
a = (V*sqrt(D)) * [cos(t(:))'; sin(t(:))'];

hold on;
h = plot(10.^(a(1, :)+mu(1)), 10.^(a(2, :)+mu(2)), cspec);
hold off;

if nargout==0; clear h; end % remove output if none requested

end
