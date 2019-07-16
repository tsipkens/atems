%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [ PixSiZe ] = TEM_pix_size(mainfolder)
%Finding TEM Magnification
%   Searching TEM image for bar lenght and it's coresponding size
%   To use this function, put the TEM image on global variable 'Processing_im'

global Processing_im

cd(mainfolder);

xs=811; ys=1108; % Coordinate of the magnification data in the image

if exist('TEMfont.mat','file')==2 % Loading TEM font data
    load('TEMfont.mat');
else
    error('Cannot find the character recognition font')
end

blank=ones(12,5); % blank font
blank=blank.*255;

numdigit=1;

%% Recognizing character
while isnotequal(Processing_im(ys:ys+11,xs-2:xs+11-2),kali)
    
    if Processing_im(ys:ys+11,xs:xs+7)==nol
        digit(1,numdigit)=0;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==satu
        digit(1,numdigit)=1;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==two
        digit(1,numdigit)=2; %#ok<*AGROW>
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==three
        digit(1,numdigit)=3;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==four
        digit(1,numdigit)=4;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==five
        digit(1,numdigit)=5;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==six
        digit(1,numdigit)=6;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==seven
        digit(1,numdigit)=7;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==eight
        digit(1,numdigit)=8;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs:xs+7)==nine
        digit(1,numdigit)=9;
        xs=xs+13;
    elseif Processing_im(ys:ys+11,xs-2:xs+11-2)==kali
        break

    end
    numdigit=numdigit+1;
    
end

numdigit=numdigit-1;
tempval=0;

%% Calculation
for i=1:numdigit
    tempval=tempval+digit(1,i)*(10^(numdigit-i)); %Calculating the magnification
end

PixSiZe = 213524*tempval^(-1.001); % Equation to calculate the pixel size



