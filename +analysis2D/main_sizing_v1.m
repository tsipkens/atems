
clc;
clear;
% close all;

load('+analysis2D/im_out_v1.mat')

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


    
    %{

    
    
    
%     BW = (im_out>0)-(bg>0);
%     BW = BW-t0;
%     BW = bwareaopen(BW,i_vec(ii)^2);
    
%     figure(2); colormap gray;
%     imagesc(BW); axis image;    
%     imagesc(BW2); axis image;
    
    BW = edge(bg,'canny');
    [centers0,radii0] = imfindcircles(BW,[i_vec(ii)-2,i_vec(ii)+2],...
        'Sensitivity',0.97,'Method','TwoStage','ObjectPolarity','Bright');
    
%     figure(2);
%     viscircles(centers0, radii0,'EdgeColor','r');

    
%     Np(ii) = sum(sum(t0>0))-sum(sum(bg>0));
    
%     t0 = BW;
    
%     D = bwdist(im_out==0);
%     
%     BW2 = edge(bg,'canny');
%     
%     [centers,radii] = imfindcircles(BW2,[ii-1,ii+1],'Sensitivity',0.99);
%     bool1 = im_out([round(centers(:,2)),round(centers(:,1))])==0;
%     centers(bool1,:) = [];
%     radii(bool1,:) = [];
%     
%     figure(4); colormap gray;
%     imagesc(BW); axis image;
%     
%     viscircles(centers0, radii0,'EdgeColor','r');
    
    for jj=1:length(centers0(:,1))
%         figure(3); colormap gray;
%         imagesc(im_orig); axis image;
%         viscircles(centers0(jj,:), radii0(jj,:),'EdgeColor','r');
        
        mask = ((centers0(jj,1)-x).^2+(centers0(jj,2)-y).^2)<(radii0(jj,1).^2);
        t0 = im_out(mask);
        t_std = std(t0);
        if t_std<0.03
%             disp('Found!');
%             
%             figure(3); colormap gray;
%             imagesc(im_orig); axis image;
%             viscircles(centers0(jj,:), radii0(jj,:),'EdgeColor','r');
            
            centers = [centers0(jj,:);centers];
            radii = [radii0(jj,:);radii];
        end
    end
    
%     if ~isempty(centers)
%         xc = centers(:,1);
%         yc = centers(:,2);
%         [xx,yy] = meshgrid(1:N(2),1:N(1));
%         mask = false(N(1),N(2));
%         for jj = 1:numel(radii)
%             mask = mask | hypot(xx - xc(jj), yy - yc(jj)) <= radii(jj);
%         end
%     else
%         mask = im_out.*0;
%     end
%     
%     im_out = im_out.*(1-mask);
%     mask = bwareaopen(im_out>0,i_vec(ii)^2);
%     im_out = im_out.*(mask-(im_out>0)+1);
    
%     
%     figure(2); colormap gray;
%     imagesc(im_out); axis image;
    
%     pause(0.01)

%     figure(4); colormap gray;
%     imagesc(im_out.*(bg>0)); axis image;
    
    
%     im_out = bg;
    %}
end
   

%%

figure(3); colormap gray;
imagesc(im_orig); axis image;
viscircles(centers, radii,'EdgeColor','r');


