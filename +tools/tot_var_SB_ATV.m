
% TOT_VAR_SB_ATV Split Bregman Anisotropic Total Variation Denoising
% Author: Timothy Sipkens
% Date:   10-10-2019
%
% Split Bregman Anisotropic Total Variation Denoising
%
%   u = arg min_u 1/2||u-g||_2^2 + mu*ATV(u)
%   
%   g : noisy image
%   mu: regularisation parameter
%   N : dimension of image
%   u : denoised image
%
% Refs:
%  *Goldstein and Osher, The split Bregman method for L1 regularized problems
%   SIAM Journal on Imaging Sciences 2(2) 2009
%  *Micchelli et al, Proximity algorithms for image models: denoising
%   Inverse Problems 27(4) 2011
%
% Benjamin Trémoulhéac
% University College London
% b.tremoulheac@cs.ucl.ac.uk
% April 2012
%
% Modified by Timothy Sipkens
% October 2019
%=========================================================================%

function u = tot_var_SB_ATV(g,mu,N)

g = g(:); % vectorize data

n = length(g);
[B,Bt,BtB] = diff_oper(N);
b = zeros(2*n,1);
d = b;
u = g;
err = 1;
kk = 1;
tol = 1e-3; % tolerance
lambda = 1;

while err > tol % iterate until error drop below tolerance
    up = u;
    [u,~] = cgs(speye(n)+BtB, g-lambda*Bt*(b-d),...
        1e-5,100); 
    Bub = B*u+b;
    d = max(abs(Bub)-mu/lambda,0).*sign(Bub);
    b = Bub-d;
    err = norm(up-u)/norm(u);
    
    kk = kk+1;
end

end


%== DIFF_OPER ============================================================%
%   Differential operator
function [B,Bt,BtB] = diff_oper(N)

D = spdiags([-ones(N(2),1) ones(N(2),1)], ...
    [0 1], N(2),N(2)+1);
D(:,1) = [];
D(1,1) = 0;
B = [kron(speye(N(1)),D) ; kron(D,speye(N(1)))];

Bt = B';
BtB = Bt*B;

end
