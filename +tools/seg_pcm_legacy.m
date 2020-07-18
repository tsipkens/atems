
% SGE_PCM_LEGACY  Script for extracting the outline of aggregates from archived PCM output images.
%     This script is used to extract the binary mask from legacy PCM output 
%     images, where an outline is drawn on top of the TEM image but 
%     the binary was not saved. The original TEM is required for 
%     reconstructing the mask; the outline is extracted from the 
%     difference of the two images, then binarized and filled. The 
%     process is repeated for all images and the output is stored 
%     in a separate folder.
% 
%     Developed and tested using flare TEM iamges from 2018, with 
%     L9_DW having a blurry fill for the result. Theorised 
%     to be due to the blurry nature of that set of TEM images 
%     which caused the binarization to erroenous recognize edges inside 
%     of aggregates.
%     
%     Last known to work on Matlab version 2019b, no additional 
%     libraries necessary.
% 
% Author:   Lawrence Zhou, 2020-06-25
% Updated:  Timothy Sipkens,2020-07-09
%=========================================================================%

clear;
close all;
clc;

% Folder locations to be replaced
f_sub_vec = {'diesel-25%\','diesel-50%\','diesel-75%\','diesel-idle\',...
    'lng-high\','lng-med\','lng-low\','lng-idle\'};

for ss=1:length(f_sub_vec) % loop through subfolders
    disp(['Processing ',num2str(ss),' of ',...
        num2str(length(f_sub_vec)),'...']);
    f_sub = f_sub_vec{ss};
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

        % f_name = strrep(f_name,'Seaspan_','');
            % account for discrepency in Seaspan images
            % comment/uncomment to consider other variation
        
        try % skip missing images
            tem = imread([f_tem,f_name]);
        catch
            disp([f_name,': original TEM not found.']);
            continue
        end

        img_cropped = tem(1:size(pcm,1), :);         % Crop out footer
        img_grey = imsubtract(img_cropped, pcm);	 % Extract outline in grayscale

        % Fill in background and background enclosed by aggregate
        img_binary = imbinarize(img_grey);
        
        try
            [B,L,N,A] = bwboundaries(img_binary, 8, 'holes');
        catch
            disp([f_name,': too many objects found.']);
            continue
        end
        
        [r,~] = find(A(:,N+1:end));                 % Find inner boundaries (enclosed by aggregate)
        [rr,~] = find(A(:,r));                      % Area enclosed by inner boundaries
        idx = setdiff(1:numel(B), [r(:);rr(:)]);    % Exclude inner area from fill
        res = ismember(L,idx);                      % Filled image
        
        res = ~bwareaopen(~res, 25);                 % Remove small background pixels
        
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
    
    disp('Complete.');
    disp(' ');
end


