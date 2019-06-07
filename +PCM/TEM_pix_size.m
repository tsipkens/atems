function [ PixSize ] = TEM_pix_size
% Automatic detection of the TEM image magnification ans pixel size
% Only works for images taken at UBC bioimaging facility after 2013
% Function to be used with the Pair Correlation Method (PCM) package
% Ramin Dastanpour & Steven N. Rogak
% Developed at the University of British Columbia
% Last updated in Feb. 2016
% Searches the TEM image for Direct Magnification value. Magnification is
% converted to the pixel size [nm/pixel] using regressions to magnification
% vs. PixSize data

%% Hosekeeping
global Img mainfolder
cd(mainfolder);

% Approximate coordinate of the scale bar data in image
xs=811; ys=1108;
if exist('TEMfont.mat','file')==2 % Loading TEM font data
    load('TEMfont.mat');
else
    error('Cannot find the character recognition font')
end

%% Recognizing characters
numOFdigits=1;
while ~isequal(Img.Processing(ys:ys+11,xs-2:xs+11-2),kali)
    if Img.Processing(ys:ys+11,xs:xs+7)==nol
        digit(1,numOFdigits)=0;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==satu
        digit(1,numOFdigits)=1;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==two
        digit(1,numOFdigits)=2;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==three
        digit(1,numOFdigits)=3;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==four
        digit(1,numOFdigits)=4;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==five
        digit(1,numOFdigits)=5;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==six
        digit(1,numOFdigits)=6;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==seven
        digit(1,numOFdigits)=7;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==eight
        digit(1,numOFdigits)=8;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs:xs+7)==nine
        digit(1,numOFdigits)=9;
        xs=xs+13;
    elseif Img.Processing(ys:ys+11,xs-2:xs+11-2)==kali
        break
    end
    numOFdigits=numOFdigits+1;
end
numOFdigits=numOFdigits-1;
DirectMag=0;

%% Building the magnification number
for i=1:numOFdigits
    DirectMag=DirectMag+digit(1,i)*(10^(numOFdigits-i));
end

%% Converting magnification number to pixel size. Derived from regression
PixSize = 213524*DirectMag^(-1.001);

