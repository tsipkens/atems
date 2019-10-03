
I = Imgs(1).cropped;


N = size(I);
mu = 15;
I_atv = reshape(...
    tools.tot_var_SB_ATV(double(I(:)),mu,N),N);
I_atv = uint8(I_atv);
featureSet = cat(3,...
    I_atv,255-I_atv);


nrows = size(I,1);
ncols = size(I,2);
[X,Y] = meshgrid(1:ncols,1:nrows);
featureSet = cat(3,featureSet,featureSet,X,Y);


L2 = imsegkmeans(featureSet,2,'NormalizeInput',true);

C = labeloverlay(I,L2);
imshow(C);
