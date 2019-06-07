%% This file partially demonstrates the Split Bregman method for Total Variation denoising
%
%   SB_ATV.m  Split Bregman Anisotropic Total Variation Denoising
%   SB_ITV.m  Split Bregman Isotropic Total Variation Denoising
%
% Benjamin Trémoulhéac
% University College London
% b.tremoulheac@cs.ucl.ac.uk
% April 2012

clc; clear all;

f = double(imread('..\Images\20180529_A9_007.TIF'));
f = f(1:1900,101:2200);
% f = double(imread('+SplitBregmanTVdenoising\Lena512.png'));
N = size(f);
n = prod(N);

f_max = max(max(f));
f = (f_max-f)-min(min(f));

g = f(:);

mu = 20;
disp('Performing total variation denoising...');
g_denoise_atv = totalVar.SB_ATV(g,mu,N);
% g_denoise_itv = totalVar.SB_ITV(g,mu);
disp('Denoising complete.');

%%
f1 = reshape(g_denoise_atv,N);
se = strel('disk',120);
bg = imopen(f1,se);
f1 = f1-bg;
f1 = f1./max(max(f1)); % convert to 0-1 greyscale for further analysis

close all;

f2 = f1;
th1 = max([f2(1,1),f2(1,end),...
    f2(end,1),f2(end,end)]);
th = th1.*1.3; % set threshold as 30% above background in the corners

%-- Thresholding ------%
BW = f1>th;

% BW = imbinarize(f1);

% T = adaptthresh(f1,0.1);
% BW = imbinarize(f1,T);

[L,nL] = bwlabel(BW);
L = imclearborder(L);
for ii=1:(max(max(L))-1)
    if sum(sum(L==ii))==0
        L(L>ii) = L(L>ii)-1;
    elseif sum(sum(L==ii))<60 % remove labels with fewer than 30 pixels
        L(L==ii) = 0;
        L(L>ii) = L(L>ii)-1;
    end
end
B = bwboundaries(L>0);

figure; colormap gray;
imagesc(f); axis image; title('Original');
for kk=1:length(B)
    boundary = B{kk};
    hold on;
    plot(boundary(:,2),boundary(:,1),'r');
    hold off;
end

figure; colormap gray;
imagesc(reshape(g_denoise_atv,N)); axis image; 
title('Anisotropic TV denoising');

figure; colormap gray;
imagesc(bg); axis image; 

figure; colormap gray;
imagesc(f1); axis image; 

figure; colormap gray;
imagesc(reshape(f1>th,N)); axis image; 

% figure; colormap gray;
% imagesc(reshape(g_denoise_itv,N,N)); axis image; 
% title('Isotropic TV denoising');

L2 = labeloverlay(imadjust(int16(f)),L,...
    'Colormap','jet','Transparency',0.75);

figure;
imagesc(L2); axis image;  

%%
idx = imsegkmeans(int16(f1.*f_max),7);

figure; colormap gray;
imagesc(idx); axis image;

BWk = idx>1; % thresholding
[Lk,nLk] = bwlabel(BWk);
Lk = imclearborder(Lk);
for ii=1:(max(max(Lk))-1)
    if sum(sum(Lk==ii))==0
        Lk(Lk>ii) = Lk(Lk>ii)-1;
    elseif sum(sum(Lk==ii))<60 % remove labels with fewer than 30 pixels
        Lk(Lk==ii) = 0;
        Lk(Lk>ii) = Lk(Lk>ii)-1;
    end
end
Bk = bwboundaries(Lk>0);

Lk2 = labeloverlay(imadjust(int16(f)),Lk,...
    'Colormap','jet','Transparency',0.75);

figure;
imagesc(Lk2); axis image; 

figure; colormap gray;
imagesc(f); axis image; title('Original');
for kk=1:length(Bk)
    boundary = Bk{kk};
    hold on;
    plot(boundary(:,2),boundary(:,1),'r');
    hold off;
end
for kk=1:length(B)
    boundary = B{kk};
    hold on;
    plot(boundary(:,2),boundary(:,1),'b');
    hold off;
end

im_out= reshape(f,N).*(L==3);

