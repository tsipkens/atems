
% FIND_CENTERS Computes the intersection of the two lines to get particle center.
% Author: Yeshun (Samuel) Ma, Timothy Sipkens, 2019-07-12
% Notes:
%   x,y,a,b are single column vectors of two entries denoting the x or y
%   coordinate at the points the user had clicked on the image during
%   primary particle sizing.
%
%   Utilizes derived formulae to compute the intersection of the linear
%   functions composed of the provided parameters.  Returns center: a
%   two column vector corresponding to the x and y coordinates of the
%   primary particle
%=========================================================================%

function centers = find_centers(x,y,a,b)

tol = 1e-10; % used to prevent division by zero

%-- Initialize xy parameters ---------------------------------------------%
x1 = x(1);
x2 = x(2);
if x1==x2; x1 = x1+tol; end % prevents division by zero
y1 = y(1);
y2 = y(2);
if y1==y2; y1 = y1+tol; end % prevents division by zero

%-- Initialize ab parameters ---------------------------------------------%
a1 = a(1);
a2 = a(2);
if a1==a2; a1 = a1+tol; end % prevents division by zero
b1 = b(1);
b2 = b(2);
if b1==b2; b1 = b1+tol; end % prevents division by zero

%-- Compute slopes -------------------------------------------------------%
m = (y1-y2)./(x1-x2);    % For xy line (vectorized)
n = (b1-b2)./(a1-a2);    % For ab line
if m==n; m = m+tol; end % prevents division by zero

%-- Assign appropriate fields and return ---------------------------------%
centers(1,:) = (b1-y1-n.*a1+m.*x1)./(m-n); % x-coordinate
centers(2,:) = (centers(1,:)-a1).*n+b1; % y-coordinate

end

