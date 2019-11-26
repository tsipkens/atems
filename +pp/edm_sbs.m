
% EDM_SBS Performs Euclidean distance mapping-scale based analysis. 
%         Based on the work of Bescond et al., Aerosol Sci. Technol. (2014).
% Author: Timothy Sipkens, 2019-11-23
%=========================================================================%

function [Aggs,S,dp_bin] = edm_sbs(img_binary,pixsize)


%-- Parse inputs ---------------------------------------------------------%
if ~exist('pixsize','var'); pixsize = []; end
%-------------------------------------------------------------------------%


%== STEP 1: Morphological opening of binary image ========================%
se_max = 150;
se_vec = 0:se_max; % vector of disk sizes (in pixels) used in opening

disp('Performing morphological operations:');
tools.textbar(0);
counts = zeros(length(se_vec),1); % initialize counts

for ii=1:length(se_vec) % loop with increasing disk size
    se = strel('disk',se_vec(ii),8);
    img_opened = imopen(img_binary,se);
        % open the image using a disk of size se_vec(ii)
        
    counts(ii) = nnz(img_opened);
        % count the number of non-zero pixels remaining
    
    tools.textbar(ii/length(se_vec));
    
    if counts(ii)==0 % if all of the pixels are gone, exit loop
        counts(ii:end) = 0;
        tools.textbar(1);
        break;
    end
        
end
counts = counts./counts(1);
disp(' ');

dp_count = (se_vec.*pixsize)';


%== STEP 2: Interpolate data to a common set of sizes ====================%
%   Accommodates images with different pixel size onto a common scale
d_max = 120;
nb_classes = 200;
dp_bin_delta = d_max/(nb_classes-1);
dp_bin = (0:dp_bin_delta:d_max)';

gi = griddedInterpolant(dp_count,counts);
S = gi(dp_bin);


%== Fit a sigmoid function to the data ===================================%
bet = 1.9; % beta parameter in sigmoid function
ome = 0.8; % Omega parameter in sigmoid function
sigmoid = @(x) 1-1./(1+exp(((log(x(1))-log(dp_bin))./log(x(2))-bet)./ome));
    % x(1) = dpg, x(2) = spg

disp('Fitting curve to data...');
opts = optimset('Display','off');
x0 = [30,1.5];
x1 = lsqnonlin(@(x) sigmoid(x)-S, x0, [], [], opts);
disp('Complete.');
disp(' ');

Aggs.dpg = x1(1);
Aggs.sg = x1(2);

end
