%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [ perimeter ] = Perimeter_Length(Final_Binary,pixsize,area_pixelcount )
%Perimeter_Length calculates the lengt of aggregate perimeter

[row, col]=find(Final_Binary);
perimeter_pixelcount=0;

for k = 1:1:area_pixelcount
    if (Final_Binary(row(k)-1, col(k)) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (Final_Binary(row(k), col(k)+1) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (Final_Binary(row(k), col(k)-1) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    elseif (Final_Binary(row(k)+1, col(k)) == 0)
        perimeter_pixelcount = perimeter_pixelcount + 1;
    end
end

perimeter=perimeter_pixelcount * pixsize;

end

