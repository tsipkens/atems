
% EDM_SBS Performs Euclidean distance mapping-scale based analysis. 
%         Based on the work of Bescond et al., Aerosol Sci. Technol. (2014).
% Author: Timothy Sipkens, 2019-11-23
%=========================================================================%

function [Aggs,dp_bin,S,S_fit] = edm_sbs(imgs_binary,pixsizes)


%-- Parse inputs ---------------------------------------------------------%
if isstruct(imgs_binary) % consider case that Aggs is given as input
    Aggs0 = imgs_binary;
    pixsizes = [Aggs0.pixsize];
    imgs_binary = {Aggs0.binary};
    Aggs = Aggs0;
elseif ~iscell(imgs_binary)
    imgs_binary = {imgs_binary};
    Aggs = struct([]); % initialize Aggs structure
else
    Aggs = struct([]); % initialize Aggs structure
end

if ~exist('pixsizes','var'); pixsizes = []; end
if isempty(pixsizes); pixsizes = 1; end
if length(pixsizes)==1; pixsizes = pixsizes.*ones(size(imgs_binary)); end
%-------------------------------------------------------------------------%


%-- Discretization for accumulated S curve -------------------------------%
d_max = 100;
nb_classes = 250;
dp_bin = logspace(log10(1),log10(d_max),nb_classes)';
S = zeros(size(dp_bin)); % initialize S curve


%-- Main loop over images ------------------------------------------------%
for aa=1:length(imgs_binary)  % loop over aggregates
    disp(['<== AGGREGATE ',num2str(aa),' of ',num2str(length(imgs_binary)),' ==>']);

    img_binary = imgs_binary{aa};
    pixsize = pixsizes(aa);


    %== STEP 1: Morphological opening of the binary image ================%
    se_max = 150;
    se_vec = 0:se_max; % vector of disk sizes (in pixels) used in opening

    disp('Performing EDM-SBS...');
    disp('Performing morphological operations:');
    tools.textbar(0);
    counts = zeros(length(se_vec),1); % initialize counts

    for ii=1:length(se_vec) % loop with increasing disk size
        se = strel('disk',se_vec(ii),8);
        img_opened = imopen(img_binary./255,se);
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


    %== STEP 2: Interpolate data to a common set of sizes ================%
    %   Accommodates images with different pixel size onto a common scale
    gi = griddedInterpolant(dp_count,counts);
    Sa = gi(dp_bin);
    
    %== STEP 3: Fit a sigmoid function to the data =======================%
    %   This consistutes aggregate-level fitting. Aerosol-level fitting is
    %   done at the end of this function.
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
    disp(' ');
    
    Aggs(aa).dpg_edm = x1(1);
    Aggs(aa).sg_edm = x1(2);
    
    
    S = S+Sa; % add to assumulated S curve

end % end loop over aggregates
S = S./S(1); % normalize S curve


%== Fit a sigmoid function to all of the data ============================%
bet = 1.9; % beta parameter in sigmoid function
ome = 0.8; % Omega parameter in sigmoid function
sigmoid = @(x) 1-1./(1+exp(((log(x(1))-log(dp_bin))./log(x(2))-bet)./ome));
    % x(1) = dpg, x(2) = spg

disp('Fitting curve to all of the data...');
opts = optimset('Display','off');
x0 = [30,1.5];
x1 = lsqnonlin(@(x) sigmoid(x)-S, x0, [], [], opts);
S_fit = sigmoid(x1);
disp('Complete.');
disp(' ');

Aggs(1).dpg_tot_edm = x1(1);
Aggs(1).sg_tot_edm = x1(2);

end
