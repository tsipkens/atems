function [ PixSize ] = TEM_pix_size2013
% Automatic detection of the TEM image magnification ans pixel size
% Only works for images taken at UBC bioimaging facility preior to 2013
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% Searches the TEM image for Direct Magnification value. Magnification is
% converted to the pixel size [nm/pixel] using regressions to magnification
% vs. PixSize data

%% Hosekeeping
global Img mainfolder
cd(mainfolder)

% Approximate coordinate of the magnification data in image
xs=1768; ys=2247;
if exist('TEMfont2013.mat','file')==2 % Loading TEM font data
    load('TEMfont2013.mat');
else
    error('Cannot find the character recognition font')
end

%% Recognizing characters
numOFdigits=1;
while ~isequal(Img.Processing(ys:ys+29,xs:xs+26),ex)
    if Img.Processing(ys:ys+29,xs:xs+22)==nol
        digit(1,numOFdigits)=0;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==yek
        digit(1,numOFdigits)=1;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==two
        digit(1,numOFdigits)=2; %#ok<*AGROW>
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==three
        digit(1,numOFdigits)=3;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==four
        digit(1,numOFdigits)=4;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==five
        digit(1,numOFdigits)=5;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==six
        digit(1,numOFdigits)=6;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==seven
        digit(1,numOFdigits)=7;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==eight
        digit(1,numOFdigits)=8;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+22)==nine
        digit(1,numOFdigits)=9;
        numOFdigits=numOFdigits+1;
        xs=xs+24;
    elseif Img.Processing(ys:ys+29,xs:xs+26)==ex
        break
    else
    xs=xs+1;    
    end
end

numOFdigits=numOFdigits-1;
DirectMag=0;

%% Building the magnification number
for i=1:numOFdigits
    DirectMag=DirectMag+digit(1,i)*(10^(numOFdigits-i)); %Calculating the magnification
end

%% Converting magnification number to pixel size. Derived from regression
PixSize = 7.2022e+04*DirectMag^(-1);

