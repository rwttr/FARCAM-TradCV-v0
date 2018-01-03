% 1

% RUN this module first  
% read the input image and do some preprocessing 

addpath('Image_acq');
IMGPATH = 'Image_acq/RES/N6_M1/nT1_L1.jpg';

%I_rgb = imread('Image_acq/RES/C910_M1/T1_L2.jpg'); %Source IMG
I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

M_DISK_SIZE = 10;
M_BLUR_SIGMA = 3;
%Generate Morphological BG
bg_disk = imopen(I_hsv3,strel('disk',M_DISK_SIZE));
bg_disk_blur = imgaussfilt(bg_disk,M_BLUR_SIGMA); % Smooth version 2sigma
bg_disk_blur = imadjust(bg_disk_blur);
%Subtract Source with BG
%I_tmp  = I_hsv3 - bg_disk;              % Morp BG
%I_tmp_blur = I_hsv3 - bg_disk_blur;     % Morp BG with Gaussian Blur
%I_tmp_blur_adj = imadjust(I_tmp_blur);  % Enhance Contrast
%I1 = imgaussfilt(I_tmp_blur_adj,10);   % Smooth I_tmp_blur_adj


%edge detection
TH_SOBEL = 0.018;
TH_CANNY = 0.15;
%I_sobel = edge(I_tmp_blur_adj,'sobel',Sobel_threshold);
%I_canny = edge(I_tmp_blur_adj,'canny',Canny_threshold);

I_sobel = edge(bg_disk_blur,'sobel',TH_SOBEL);
I_canny = edge(bg_disk_blur,'canny',TH_CANNY);

I_sobel2 = edge(I_hsv3,'sobel',TH_SOBEL);
I_canny2 = edge(I_hsv3,'canny',TH_CANNY);

%Display Image
%{
figure('Name', 'Enchaced Image');
subplot(1,3,1);
imshow(I_tmp);title('Subtracted from Morp BG');
subplot(1,3,2);
imshow(I_tmp_blur);title('Subtracted from Morp+Blur');
subplot(1,3,3);
imshow(I_tmp_blur_adj);title('with contrast adj');
%}

figure('Name','Morphological Background');
subplot(1,2,1);           
imshow(bg_disk);title('Disk Morph');
subplot(1,2,2); 
imshow(bg_disk_blur);title('WithBlur+Contrast Adj');    

figure('Name','Inverted Binary Image: Edge detection');
subplot(1,2,1);               
imshow(I_sobel);title('Sobel');   
subplot(1,2,2);               
imshow(I_canny);title('Canny');   



