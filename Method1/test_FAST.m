%Matlab computer vision toolbox
% FAST corner detection

I_rgb = imread('Image_acq/IMG_nexus.jpg');
I_hsv = rgb2hsv(I_rgb);

Isize = size(I_hsv);

%display v-channel (hsv)
imshow(I_hsv(1:Isize(1),1:Isize(2),3)) 

%corner detector
corners = detectFASTFeatures(I_hsv(:,:,3),'MinContrast',0.1);
I_hsv3_marker = insertMarker(I_rgb,corners,'circle');
imshow(I_hsv3_marker)

% gaussian filter sigma = 3 (square matrix n3)
%I_hsv3blur = imgaussfilt(I_hsv(:,:,3),3);
%imshow(I_hsv3blur)

