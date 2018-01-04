% Read Kmeans Image Patch and Extract texture feature

% resize to 120*120px @ Source Image 1024px Height
% input image

%{
IMGPATH = 'C:\Users\Rattachai\Desktop\tapCrop1\39.jpg';
I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value
I_toext = I_hsv3;


[r,c] = size(I_toext);
W_mask_tukey = window2(r,c,@tukeywin); 
W_mask_hamming = window2(r,c,@hamming);
W_mask_hann = window2(r,c,@hamming);% not zero at ending
I_toext_w_tukey = I_toext.*W_mask_tukey;
I_toext_w_hamming = I_toext.*W_mask_hamming;
I_toext_w_hann = I_toext.*W_mask_hann;

figure('Name','window function Mask : Tukey');
imshowpair(I_toext,I_toext_w_tukey,'montage');

figure('Name','window function Mask : Hann');
imshowpair(I_toext,I_toext_w_hann,'montage');

figure('Name','window function Mask : Hamming');
imshowpair(I_toext,I_toext_w_hamming,'montage');
%} 
IMG_SQ_RZ = 120;
inputIMGtexture = I_toext;

inputIMGtexture_rz = imresize(inputIMGtexture,[IMG_SQ_RZ IMG_SQ_RZ]); 
% Bicubic interpolation Resizing method

W_mask_tukey = window2(IMG_SQ_RZ,IMG_SQ_RZ,@tukeywin); 
W_mask_hamming = window2(IMG_SQ_RZ,IMG_SQ_RZ,@hamming);
W_mask_hann = window2(IMG_SQ_RZ,IMG_SQ_RZ,@hamming);% not zero at ending

%inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_tukey;
%inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_hamming;
inputIMGtexture_rz = inputIMGtexture_rz.*W_mask_hann;

figure('Name','Resized Image');
imshow(inputIMGtexture_rz);
title('Resized image');

% ///////////////////////////////////////////////////////
% Texture Analysis compute on inputIMGrz
% ///////////////////////////////////////////////////////

% Structural Analysis : Fourier Transform
F_IMG = fft2(inputIMGtexture_rz);
%figure();  imagesc(abs(fftshift(F_IMG)))

rF_IMG = abs(F_IMG);    % magnitude response
rF_IMG(1,1) = 0;        % ignore zero-freqency component

%normailized fourier coefficient
nF_IMG = abs(fftshift(F_IMG))/sqrt(sumsqr(rF_IMG));

% measurement as a single feature
fenergy_I = sumsqr(nF_IMG);           % energy:e
fentro_log = nF_IMG.*log2(nF_IMG);
fentro_I = sum(sum(fentro_log,1),2);  % entropy:h
                                      % inertia:i 
                                      
textFeature_frir = [fenergy_I fentro_I];                                      

% Statistical Analysis : Co-occurrence Matrix
% Gray-Level Co-occurrence Matrices (GLCMs)
glcms = graycomatrix(inputIMGtexture_rz);
ccontrast_I = graycoprops(glcms,'Contrast');
ccorela_I = graycoprops(glcms,'Correlation');
cenergy_I = graycoprops(glcms,'Energy');
chomog_I = graycoprops(glcms,'Homogeneity');

textFeature_stat = [ccorela_I cenergy_I chomog_I ccontrast_I];





