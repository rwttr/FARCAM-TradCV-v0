% 1

% RUN this module first  
% read the input image and do some preprocessing 

% Image Enhancement
addpath('Image_acq');

% test @40-80 lux on tree surface

I_rgb = imread('Image_acq/RES/n6_M1/nT10_L1.jpg'); %Source IMG
I_hsv = rgb2hsv(I_rgb);

I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

%Enhance contrast using histogram equalization map to grey
%128 grey level
%J = histeq(I_hsv3,128);

%Generate Morphological BG
bg_disk = imopen(I_hsv3,strel('disk',12));
bg_disk_blur = imgaussfilt(bg_disk,1); % Smooth version 2sigma
bg_disk_blur = imadjust(bg_disk_blur);
%Subtract Source with BG
I_tmp  = I_hsv3 - bg_disk;              % Morp BG
I_tmp_blur = I_hsv3 - bg_disk_blur;     % Morp BG with Gaussian Blur
I_tmp_blur_adj = imadjust(I_tmp_blur);  % Enhance Contrast
%I1 = imgaussfilt(I_tmp_blur_adj,10);   % Smooth I_tmp_blur_adj


%edge detection
Sobel_threshold = 0.03;
Canny_threshold = 0.22;
%I_sobel = edge(I_tmp_blur_adj,'sobel',Sobel_threshold);
%I_canny = edge(I_tmp_blur_adj,'canny',Canny_threshold);

I_sobel = edge(bg_disk_blur,'sobel',Sobel_threshold);
I_canny = edge(bg_disk_blur,'canny',Canny_threshold);

%remove connected 10 piexel in BW image
%test = bwareaopen(I_sobel,10);


%Display Image
figure('Name', 'Enchaced Image');
subplot(1,3,1);
imshow(I_tmp);title('Subtracted from Morp BG');
subplot(1,3,2);
imshow(I_tmp_blur);title('Subtracted from Morp+Blur');
subplot(1,3,3);
imshow(I_tmp_blur_adj);title('with contrast adj');

figure('Name','Morphological Background');
subplot(1,2,1);           
imshow(bg_disk);title('Generated BG');
subplot(1,2,2); 
imshow(bg_disk_blur);title('With Gaussian Blur');    

figure('Name','Inverted Binary Image: Edge detection');
subplot(1,2,1);               
imshow(I_sobel);title('Sobel');   
subplot(1,2,2);               
imshow(I_canny);title('Canny');   



