%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Written by Ramin Dastanpour, Steve Rogak, Hugo Tjong, Arka Soewono %%%
%%%% The University of British Columbia, Vanouver, BC, Canada, Jul. 2014%%%
%%%% If you use this code or any modified version of it, you are expected
%%%% to refere to the the main developers and appropriate articles, e.g. 
%%%% "Observations of a Correlation between Primary Particle and Aggregate
%%%% Size for Soot Particles", J. of Aerosol Sci. & Tech.

function[datanum datatxt]=excellimport(filename,sheetnumber)
%Importing data from .xls file
%
[~,sheets,~] = xlsfinfo(filename); %finding info about the excel file
sheetname=char(sheets(1,sheetnumber)); % choosing the second sheet
[datanum datatxt]=xlsread(filename,sheetname); %loading the data
