%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [Rg] = gyration(Final_Binary, pixsize)
%Gyration calculates radius of gyration by assuming every pixel as an area
%of pixsize^2

Total_area=nnz(Final_Binary)*pixsize^2;

[xpos,ypos]=find(Final_Binary);
n_pix=size(xpos,1);
Centroid.x=sum(xpos)/n_pix;
Centroid.y=sum(ypos)/n_pix;

Ar2=zeros(n_pix,1);

for k=1:n_pix
    Ar2(k,1)=(((xpos(k,1)-Centroid.x)*pixsize)^2+((ypos(k,1)-Centroid.y)*pixsize)^2)*pixsize^2;
end

Rg = (sum(Ar2)/Total_area)^0.5;

end

