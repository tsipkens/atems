%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function [ PixSiZe ] = TEM_pix_size2013(mainfolder)
%Finding TEM Magnification
% Searching TEM image for Direct Magnification value
% This code converts Direct Magnification to nm/pixel based on curve
% fitting results

global Processing_im

cd(mainfolder)

%% Step1-1: Detecting Magnification and TEM_pix_size
        
xs=1768; ys=2247; % Coordinate of the magnification data in the image

if exist('TEMfont2013.mat','file')==2 % Loading TEM font data
    load('TEMfont2013.mat');
else
    error('Cannot find the character recognition font')
end

blank=ones(12,5); % blank font
blank=blank.*255;

numdigit=1;
%% Recognizing character
while isnotequal(Processing_im(ys:ys+29,xs:xs+26),ex)
    
    if Processing_im(ys:ys+29,xs:xs+22)==nol
        digit(1,numdigit)=0;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==yek
        digit(1,numdigit)=1;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==two
        digit(1,numdigit)=2; %#ok<*AGROW>
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==three
        digit(1,numdigit)=3;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==four
        digit(1,numdigit)=4;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==five
        digit(1,numdigit)=5;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==six
        digit(1,numdigit)=6;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==seven
        digit(1,numdigit)=7;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==eight
        digit(1,numdigit)=8;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+22)==nine
        digit(1,numdigit)=9;
        numdigit=numdigit+1;
        xs=xs+24;
    elseif Processing_im(ys:ys+29,xs:xs+26)==ex
        break
    else
    xs=xs+1;    
    end
    
    
end

numdigit=numdigit-1;
DirectMag=0;

%% Calculation
for i=1:numdigit
    DirectMag=DirectMag+digit(1,i)*(10^(numdigit-i)); %Calculating the magnification
end

PixSiZe = 7.2022e+04*DirectMag^(-1); % Equation to calculate the pixel size;


