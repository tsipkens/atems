

load('data/agg_net.mat')

Imgs_ref = tools.get_img_ref;
    % generates a reference to a set of images to be analyzed
Imgs = tools.get_imgs(Imgs_ref); % load a single image
Imgs = tools.get_footer_scale(Imgs); % get footer for selected image

I_test = Imgs(1).cropped;


%-- Attempt to remove background gradient --------------------------------%
[X,Y] = meshgrid(1:size(I_test,2),1:size(I_test,1));
bg_fit = fit(double([X(:),Y(:)]),double(I_test(:)),'poly11');
bg = uint8(round(bg_fit(X,Y)));

t0 = double(max(max(bg))-bg);
t1 = double(I_test)+t0;
t2 = t1-min(min(t1));
I_test0 = uint8(round(255.*t2./max(max(t2))));


%-- Proceed with segmentation --------------------------------------------%
C_test = semanticseg(I_test0',net);

bw = ((C_test')=='background');

figure(1);
D_test = labeloverlay(I_test,bw);
imshow(D_test);



minparticlesize = 4.9; % to filter out noises
pixsize = Imgs(1).pixsize;
coeff_matrix = [0.2 0.8 0.4 1.1 0.4;0.2 0.3 0.7 1.1 1.8;...
    0.3 0.8 0.5 2.2 3.5;0.1 0.8 0.4 1.1 0.5];
        % coefficient for automatic Hough transformation

% Build the image processing coefficients for the image based on its
% magnification
if pixsize <= 0.181
    coeffs = coeff_matrix(1,:);
elseif pixsize <= 0.361
    coeffs = coeff_matrix(2,:);
else 
    coeffs = coeff_matrix(3,:);
end

a = coeffs(1);
b = coeffs(2);
c = coeffs(3);
d = coeffs(4);
e = coeffs(5);



disp('Morphologically closing image...');
se = strel('disk',round(a*minparticlesize/pixsize));
img_bewBW1 = imclose(bw,se);

disp('Morphologically opening image...');
se = strel('disk',round(b*minparticlesize/pixsize));
img_bewBW2 = imopen(img_bewBW1,se);

disp('Morphologically closing image...');
se = strel('disk',round(c*minparticlesize/pixsize));
img_bewBW3 = imclose(img_bewBW2,se);

disp('Morphologically opening image...');
se = strel('disk',round(d*minparticlesize/pixsize));
img_bewBW = imopen(img_bewBW3,se);
disp('Completed morphological operations.');

figure(2);
E_test = labeloverlay(I_test,img_bewBW);
imshow(E_test);


figure(3);
imshow(I_test0);


