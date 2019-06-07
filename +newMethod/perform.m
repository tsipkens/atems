
clc;
clear;
% close all;

load('Data/im_out_v1.mat')

im_orig = im_out;
im_out = im_out./max(max(im_out));

figure(1); colormap gray;
imagesc(im_out); axis image;

N = size(im_out);
Np = [];
t0 = 0.*im_out;
radii = [];
centers = [];

i_vec = 10:1:40;

for ii=1:length(i_vec)
    i_vec(ii)
    
    se = strel('disk',i_vec(ii));
    bg = imopen(im_out,se);
    
    BW = (im_out>0)-(bg>0);
    BW = BW-t0;
    BW = bwareaopen(BW,i_vec(ii)^2);
    
%     figure(2); colormap gray;
%     imagesc(BW); axis image;
    
    BW = edge(BW,'canny');

    [centers0,radii0] = imfindcircles(BW,...
        [round(i_vec(ii).*0.8),round(i_vec(ii).*1.2)],...
        'Sensitivity',0.99,'Method','TwoStage','ObjectPolarity','Bright');
    
    ind_remove = [];
    [xx,yy] = meshgrid(1:N(2),1:N(1));
    for jj=1:length(centers0(:,1))
        mask = ((centers0(jj,1)-xx).^2+(centers0(jj,2)-yy).^2)<(radii0(jj,1).^2);

        if im_out(round(centers0(jj,2)),round(centers0(jj,1)))==0
            viscircles(centers0(jj,:), radii0(jj,:),'EdgeColor','b');
            ind_remove = [ind_remove,jj];
        elseif sum(im_out(mask)==0)>(0.1.*(sum(sum(mask))))
            viscircles(centers0(jj,:), radii0(jj,:),'EdgeColor','g');
            ind_remove = [ind_remove,jj];
        end
    end
    centers0(ind_remove,:) = [];
    radii0(ind_remove,:) = [];
    
    centers = [centers0;centers];
    radii = [radii0;radii];
    
    figure(2); colormap gray;
    imagesc(im_out); axis image;
    viscircles(centers0, radii0,'EdgeColor','r');
    
end
   

%%

figure(3); colormap gray;
imagesc(im_orig); axis image;
viscircles(centers, radii,'EdgeColor','r');


