
% IMFRACT  Compute fractal dimension using the image-based defintion.
%  Uses the box-count method. 
%  
%  DF = fract(IMGS_BINARY) computes the fractal dimension for a single
%  binary mask or a cell of binary masks. 
%  
%  DF = fract(AGGS) computes the fractal dimension using the binary masks
%  in a given aggregate structure. 
%  
%  ------------------------------------------------------------------------
%  
%  AUTHOR: Timothy Sipkens, 2021-11-13

function [Df] = imfract(imgs_binary)

if isa(imgs_binary, 'struct'); imgs_binary = {imgs_binary.binary}; end

if ~iscell(imgs_binary); imgs_binary = {imgs_binary}; end


Df = zeros(length(imgs_binary), 1);
kf = Df;
for jj=1:length(imgs_binary)
    img_binary = imgs_binary{jj};
    
    s0 = size(img_binary);  % size of the original image

    incr = 1.3;  % amount of increase the length each iteration
    
    % Loop to change the length scale and recalculate the area. 
    i0 = [];
    a = min(size(img_binary));
    l = unique(round(logspace(0, log10(a / 20), 50)));
    for ii=1:length(l)
        
        i1 = imdilate(img_binary, strel('rectangle', [l(ii), l(ii)]));
        i1 = i1(round(l(ii)/2):l(ii):end, round(l(ii)/2):l(ii):end);

        i0(ii) = sum(sum(i1));  % get pixels still in the particle
        
        %{
        % Debugging figure.
        figure(gcf);
        imagesc(i1);
        colormap gray;
        %}
    end
    
    % Ignore cases where aggregate(s) disappeared. 
    l(i0 == 0) = [];
    i0(i0 == 0) = [];

    p = polyfit(log(1 ./ l), log(i0), 1);  % fit a line through this data

    %{
    % Plot fractal relationship (used to get Df and kf).
    loglog(1 ./ l, i0, '.');
    hold on;
    limx = xlim();
    loglog(limx, exp(polyval(p, log(limx))));
    hold off;
    %}
    
    Df(jj) = p(1);  % fractal dimension
    kf(jj) = p(2);  % fractal pre-factor
end

end

