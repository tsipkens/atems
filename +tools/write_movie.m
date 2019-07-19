
% WRITE_MOVIE   Generates a movie from a series of plots.
% Author:       Timothy Sipkens, 2019-07-04
%=========================================================================%

function [v] = write_movie(fname,M)

v = VideoWriter(fname,'Motion JPEG AVI');

open(v);
writeVideo(v,M);
close(v);

end

