
% EDM_SBS Performs Euclidean distance mapping-scale based analysis. 
% Based on the work of Bescond et al. (2014)
% Author: Timothy Sipkens, 2019-11-23
%=========================================================================%

function [Aggs] = edm_sbs(img_binary,pixsize)



%== STEP 1: Morphological opening of binary image ========================%
se_max = 100;
se_vec = 0:se_max;

count = zeros(length(se_vec),1);
for ii=1:length(se_vec)
    se = strel('disk',se_vec(ii));
    img_opened = imopen(img_binary,se);
    count(ii) = nnz(img_opened);
end
count = count./count(1);

dp_count = (se_vec.*pixsize)';
S = count;


%== STEP 2: Bin data after covering to nm ================================%
nb_classes = 20;
d_max = 125;
dp_bin_delta = d_max/(nb_classes-1);
dp_bin = (0:dp_bin_delta:d_max)';

% S = zeros(nb_classes,1);
% A = repmat(dp_bin,[1,length(dp_count)]);
% [~,ind_closest] = min(abs(bsxfun(@minus, A, dp_count')));
% for ii=1:length(count)
%     S(ind_closest(ii)) = S(ind_closest(ii)) + count(ii);
% end
% 
% t0 = 1-bsxfun(@minus, A, dp_count');
% t0(t0<=-1) = 0;
% t0(t0>1) = 0;
% t0 = abs(t0);
% 
% t0 = min(1,max(0,...
%     (dp_bin(2:end)-dp_count(1:(end-1))')./dp_bin_delta...
%     ));
% t1 = min(1,max(0,...
%     (dp_count(2:end)'-dp_bin(1:(end-1)))./dp_bin_delta...
%     ));
% t2 = min(t0,t1);


%== Fit a sigmoid function to the data ===================================%
beta = 1.9;
Omega = 0.8;
sigmoid = @(x) 1-1./(1+exp(((log(x(1))-log(dp_count))./log(x(2))-beta)./Omega));
    % x(1) = dpg, x(2) = spg

x0 = [30,1.5];
x1 = lsqnonlin(@(x) sigmoid(x)-S, x0);

Aggs.dpg = x0(1);
Aggs.sg = x0(2);

end
