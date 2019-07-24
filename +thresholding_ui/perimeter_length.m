%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [perimeter] = perimeter_length(img_binary,pixsize,pixels)
%Perimeter_Length calculates the lengt of aggregate perimeter

[row, col]=find(img_binary);

perimeter_pixelcount=0;

for kk = 1:1:pixels
    if (img_binary(row(kk)-1, col(kk)) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (img_binary(row(kk), col(kk)+1) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (img_binary(row(kk), col(kk)-1) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (img_binary(row(kk)+1, col(kk)) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    end
end

perimeter=perimeter_pixelcount * pixsize;

end

