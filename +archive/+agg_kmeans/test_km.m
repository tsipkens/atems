

I = Imgs(2).cropped;
I_rv = 255-I;

N = size(I_rv);

disp('mu = 15');
mu = 15;
I_denoise_atv_15 = reshape(...
    tools.tot_var_SB_ATV(double(I_rv(:)),mu,N),N);
I_denoise_atv_15 = uint8(I_denoise_atv_15);

disp('mu = 30');
mu = 30;
I_denoise_atv_30 = reshape(...
    tools.tot_var_SB_ATV(double(I_rv(:)),mu,N),N);
I_denoise_atv_30 = uint8(I_denoise_atv_30);

disp('mu = 45');
mu = 45;
I_denoise_atv_45 = reshape(...
    tools.tot_var_SB_ATV(double(I_rv(:)),mu,N),N);
I_denoise_atv_45 = uint8(I_denoise_atv_45);

disp('mu = 60');
mu = 60;
I_denoise_atv_60 = reshape(...
    tools.tot_var_SB_ATV(double(I_rv(:)),mu,N),N);
I_denoise_atv_60 = uint8(I_denoise_atv_60);

%%
nrows = size(I_rv,1);
ncols = size(I_rv,2);
[X,Y] = meshgrid(1:ncols,1:nrows);

se_20 = strel('disk',20);

featureSet = cat(3,...
    I_denoise_atv_15,...
    I_denoise_atv_30,...
    I_denoise_atv_45,...
    I_denoise_atv_60);
% featureSet = cat(3,featureSet,featureSet);
% featureSet = cat(3,featureSet,featureSet);
featureSet = cat(3,featureSet,255-featureSet,X,Y);

L2 = imsegkmeans(featureSet,2,'NormalizeInput',true);

C = labeloverlay(I,L2);
imshow(C);
