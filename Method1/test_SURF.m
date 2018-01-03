%Matlab computer vision toolbox
% SURF feature point detection


I_rgb = imread('Image_acq/IMG_nexus.jpg');
I_hsv = rgb2hsv(I_rgb);

Isize = size(I_hsv);

%display v-channel (hsv)
imshow(I_hsv(1:Isize(1),1:Isize(2),3))

I_hsv3blur = imgaussfilt(I_hsv(:,:,3),[11 1]);
imshow(I_hsv3blur);

points = detectSURFFeatures(I_hsv3blur);
imshow(I_hsv(:,:,3)); hold on;
plot(points.selectStrongest(50));