
% EDM_SBS Performs Euclidean distance mapping-scale based analysis. 
% Based on the work of Bescond et al. (2014)
% Author: Timothy Sipkens, 2019-11-23
%=========================================================================%

function [Aggs] = edm_sbs(Aggs,bool_plot)



%== Morphological opening of binary image =====%



%== Bin data after covering to nm =======%
nb_classes = 25;
d_max = 125;
dpg = [0:d_max/(nb_classes-1):d_max];


%== Fit inverse CDF to data ========%




sigmoid = @(x) 1./(1+exp(((log(x(1))-log(dpg))./log(x(2))-1)./Omega));
    % x(1) = dpg, x(2) = spg

x0 = [30,1.5];
x1 = lsqnonlin(@(x) sigmoid(x)-S, x0);

end
