
% SEG_ADAPT_RB  Performs adaptive thresholding + a rolling ball transformation.
% Author: Timothy Sipkens, 2019-11-06
%=========================================================================%

function [imgs_binary] = seg_adapt_rb(imgs, ...
    pixsizes, minparticlesize, coeffs) 

%-- Parse inputs ---------------------------------------------------------%
if ~exist('pixsizes', 'var'); pixsizes = []; end
[imgs, pixsizes, n] = agg.parse_inputs(imgs, pixsizes);
if isempty(pixsizes)
    error('PIXSIZES is a required argument unless Imgs structure is given.');
end

if ~exist('minparticlesize','var'); minparticlesize = []; end
if ~exist('coeffs','var'); coeffs = []; end

if ~exist('opts','var'); opts = struct(); end
if ~isfield(opts, 'sens'); opts.sens = 0.6; end
if ~isfield(opts, 'minsize'); opts.minsize = 1500; end
%-------------------------------------------------------------------------%


tools.textheader('Adaptive thresholding');

% Loop over images, calling seg function below on each iteration.
imgs_binary{n} = []; % pre-allocate cell

disp('Segmenting images:'); tools.textbar([0, n]);
for ii=1:n
    img = imgs{ii}; pixsize = pixsizes(ii); % values for this iteration
    
    
%== CORE FUNCTION ========================================================%
    %== Step 0b: Perform denoising of the image ==========================%
    %   New to this implementation.
    img = imbilatfilt(img);
    
    
    %== Step 1: Apply intensity threshold (Otsu) =========================%
    level = adaptthresh(img, opts.sens, ...  % applies adaptive thresholding
        'ForegroundPolarity', 'dark', ...
        'NeighborhoodSize', 16*floor(size(img)/16)+1);  % double default
    bw = ~imbinarize(img, level);
    
    % Remove some background pixels already.
    bw = bwareaopen(bw, opts.minsize/2);
    
    
    %== Step 2: Rolling Ball Transformation ==============================%
    imgs_rb = agg.rolling_ball(bw, pixsize, minparticlesize, coeffs);
    
    % Remove remaining small aggregates.
    imgs_binary{ii} = bwareaopen(imgs_rb, opts.minsize);
%=========================================================================%
    
    
    tools.textbar([ii, n]);  % if more than one image, output text
end
tools.textheader();

end
