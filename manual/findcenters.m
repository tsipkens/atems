function center = findcenters(x,y,a,b)
%FINDCENTERS Computes the intersection of the two lines formed by
%coordinates given by x,y,a,b vectors
%   x,y,a,b are single column vectors of two entries denoting the x or y
%   coordinate at the points the user had clicked on the image during
%   primary particle sizing.
%
%   Utilizes derived formulae to compute the intersection of the linear
%   functions composed of the provided parameters.  Returns center: a
%   struct with x and y fields to represent the coordinates of the center.

center = struct;

%% Initialize xy parameters
x1 = x(1);
x2 = x(2);
y1 = y(1);
y2 = y(2);

%% Initialize ab parameters
a1 = a(1);
a2 = a(2);
b1 = b(1);
b2 = b(2);

%% Compute slopes
m = (y1-y2)/(x1-x2);    % For xy line
n = (b1-b2)/(a1-a2);    % For ab line

%% Function of line dictated by xy parameters
fxy = @(x) ((x-x1)*m)+y1;

%% Assign appropriate fields and return
center.x = ((m*x1)+b1-(n*a1)-y1)/(m-n);
center.y = fxy(center.x);

end

