
% EDM_SBS Performs Euclidean distance mapping-scale based analysis. 
%         Based on the work of Bescond et al., Aerosol Sci. Technol. (2014).
% Author: Timothy Sipkens, 2019-11-23
% 
%-------------------------------------------------------------------------%
% Inputs: 
%   imgs_binary  Could be one of three options: 
%                (1) An Aggs structure, produced by other parts of this program
%                (2) A single binary image, where 1s indicate aggregate.
%                (3) A cellular arrays of the above images.
%   pixsizes     A scalar or vector contain the pixel size for each image.
%                (Not used if an Aggs structure is provided.)
% 
% Outputs: 
%   Aggs         A structure containing information for each aggregate.
%   dp_bin       The vector of particle sizes used in S curve.
%   S            The S curve as defined by Bescond et al.
%   S_fit        The fit S curve used to quantify the particle size.
%=========================================================================%

function [Aggs, dp_bin, S, S_fit] = edm_sbs(imgs_binary, pixsizes)


%-- Parse inputs ---------------------------------------------------------%
% OPTION 1: Consider case that Aggs is given as input.
if isstruct(imgs_binary)
    Aggs0 = imgs_binary;
    pixsizes = [Aggs0.pixsize];
    imgs_binary = {Aggs0.binary};
    Aggs = Aggs0;

% OPTION 2: A single binary image is given.
elseif ~iscell(imgs_binary)
    imgs_binary = {imgs_binary};
    Aggs = struct([]); % initialize Aggs structure
    
% OPTION 3: A cellular array of images is given.
else
    Aggs = struct([]); % initialize Aggs structure
    
end

% Extract or assign the pixel size for each aggregate
if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = 1; end
if length(pixsizes)==1; pixsizes = pixsizes.*ones(size(imgs_binary)); end
%-------------------------------------------------------------------------%


%-- Discretization for accumulated S curve -------------------------------%
d_max = 100;
nb_classes = 250;
dp_bin = logspace(log10(1),log10(d_max),nb_classes)';
S = zeros(size(dp_bin)); % initialize S curve


%-- Main loop over binary images -----------------------------------------%
disp('Performing EDM-SBS:');
tools.textbar(0);

for aa=1:length(imgs_binary)  % loop over aggregates

    img_binary = imgs_binary{aa};
    pixsize = pixsizes(aa);


    %== STEP 1: Morphological opening of the binary image ================%
    se_max = 150;
    se_vec = 0:se_max; % vector of disk sizes (in pixels) used in opening
    
    counts = zeros(length(se_vec),1); % initialize counts
    
    img_dist = bwdist(~img_binary); % Euclidean distance to outside of aggregate
    for ii=1:se_max
        counts(ii) = nnz(img_dist>se_vec(ii));
            % count the number of non-zero pixels remaining
            
        if counts(ii)==0 % if all of the pixels are gone, exit loop
            counts(ii:end) = 0;
            break;
        end
    end
    
    counts = counts./counts(1);

    dp_count = (se_vec.*pixsize)';


    %== STEP 2: Interpolate data to a common set of sizes ================%
    %   Accommodates images with different pixel size onto a common scale
    gi = griddedInterpolant(dp_count,counts);
    Sa = gi(dp_bin);
    
    
    %== STEP 3: Fit a sigmoid function to the data =======================%
    %   This consistutes aggregate-level fitting. Aerosol-level fitting is
    %   done at the end of this function.
    %   Constant for sigmoid function taken from original EDM-SBS code.
    bet = 1.9658; % beta parameter in sigmoid function
    ome = -0.8515; % Omega parameter in sigmoid function
    a = 0.9966;
    sigmoid = @(x) a./(1+exp(((log(x(1))-log(dp_bin))./log(x(2))-bet)./ome));
        % x(1) = dpg, x(2) = spg
    
    opts = optimset('Display','off');
    x0 = [25,1.5];
    x1 = lsqnonlin(@(x) (sigmoid(x) - Sa) ./ 100, x0, [], [], opts);
    Sa_fit = sigmoid(x1);
    
    Aggs(aa).dp_edm = x1(1); % geometric mean diameter for output
    Aggs(aa).sg_edm = x1(2); % geometric standard deviation for output
    Aggs(aa).dp = x1(1); % assign primary particle diameter based on dp_edm
    
    
    S = S+Sa; % add to assumulated S curve
    
    tools.textbar(aa/length(imgs_binary));

end % end loop over aggregates
S = S./length(imgs_binary); % normalize S curve
disp(' ');


%== Fit a sigmoid function to all of the data ============================%
bet = 1.9658; % beta parameter in sigmoid function
ome = -0.8515; % Omega parameter in sigmoid function
a = 0.9966;
sigmoid = @(x) a./(1+exp(((log(x(1))-log(dp_bin))./log(x(2))-bet)./ome));
    % x(1) = dpg, x(2) = spg

disp('Fitting curve to all of the data...');
opts = optimset('Display','off');
x0 = [25,1.5];
x1 = lsqnonlin(@(x) (sigmoid(x) - S) ./ 100, x0, [], [], opts);
S_fit = sigmoid(x1);
disp('Complete.');
disp(' ');

% report average dp and sg over the entire set of samples
% stored in the first entry of Aggs
Aggs(1).dp_edm_tot = x1(1);
Aggs(1).sg_edm_tot = x1(2);

end
