
% PCM_POST_SEG  Script for extracting the outline of aggregates from archive PCM output images.
% Author:   Lawrence Zhou, 2020-06-25
% Updated:  Timothy Sipkens,2020-07-09
% Input:    TEM image folder, PCM image folder, Output image folder
% Outputs:  Binary masks of TEM images
%=========================================================================%

clear;
close all;
clc;

% Folder locations to be replaced
f_sub = 'diesel-75%\';
f_pcm = '..\images\2018-seaspan\archive-pcm[ut]\';
f_tem = ['..\images\2018-seaspan\archive-images\',f_sub];
f_out = ['..\images\2018-seaspan\binary-processed[ts]\',f_sub];
f_tem2 = ['..\images\2018-seaspan\images\',f_sub];
f_crop = ['..\images\2018-seaspan\cropped[ts]\',f_sub];

data_tem = dir([f_tem,'*.tif']);
data_pcm = dir([f_pcm,'*.tif']);

for ii = 1:length(data_pcm)
    
    f_name = data_pcm(ii).name;
    pcm = imread([f_pcm,f_name]);

    f_name = strrep(f_name,'Seaspan_',''); % account for discrepency in Seaspan images

    % Skip missing images
    try
        tem = imread([f_tem,f_name]);
    catch
        disp([f_name,' original TEM not found.']);
        continue
    end
    
    img_cropped = tem(1:size(pcm,1), :);         % Crop out footer
    img_grey = imsubtract(img_cropped, pcm);	 % Extract outline in grayscale
    
    % Fill in background and background enclosed by aggregate
    img_binary = imbinarize(img_grey);
    [B,L,N,A] = bwboundaries(img_binary, 8, 'holes');
    [B,L,N,A] = bwboundaries(L, 8, 'holes');    % Apply a second time to fill remaining gaps
    [r,~] = find(A(:,N+1:end));                 % Find inner boundaries (enclosed by aggregate)
    [rr,~] = find(A(:,r));                      % Area enclosed by inner boundaries
    idx = setdiff(1:numel(B), [r(:);rr(:)]);    % Exclude inner area from fill
    res = ismember(L,idx);                      % Filled image
    
    if ~exist(f_out, 'dir')
       mkdir(f_out)
    end
    
    f_name = strrep(f_name,'Seaspan_',''); % account for discrepency in Seaspan images
    
    imwrite(res, [f_out, f_name]);
    
    if exist('f_tem2','var')
        if ~exist(f_tem2, 'dir')
            mkdir(f_tem2)
        end
        imwrite(tem, [f_tem2, f_name]);
        
        if ~exist(f_crop, 'dir')
            mkdir(f_crop)
        end
        imwrite(img_cropped, [f_crop, f_name]);
    end
end

