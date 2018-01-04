% HOG computation for training one-class SVM classifier

TAPPATH = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_tap\t';
LIGHT_LV = '_1.jpg';

%before loop observe matrix dimension for declaration
tree_counter = 1; %start
TAPPATH = strcat(TAPPATH,int2str(tree_counter),LIGHT_LV);
I_rgb = imread(TAPPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv3 = I_hsv(:,:,3); % Value

a = size(I_hsv3);  
[fea5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
[fea8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
[fea10,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));

%{
figure;
subplot(1,2,1);
imshowpair(I_rgb,I_hsv3,'montage');
subplot(1,2,2);
imshow(I_hsv3); 
hold on
plot(visualHOG5);
%}

nSample = 32; % no of data 

responseVec(1:nSample,1) = ones;
nCol_fea5 = size(fea5,2);
nCol_fea8 = size(fea8,2);
nCol_fea10 = size(fea10,2);

fea5_rm(nSample,nCol_fea5) = zeros;
fea8_rm(nSample,nCol_fea8) = zeros;
fea10_rm(nSample,nCol_fea10) = zeros;

fea5_rm(1,:) = fea5;
fea8_rm(1,:) = fea8;
fea10_rm(1,:) = fea10;

for tree_counter= 2:nSample
    TAPPATH = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_tap\t';
    TAPPATH = strcat(TAPPATH,int2str(tree_counter),LIGHT_LV);
    I_rgb = imread(TAPPATH);
    I_hsv = rgb2hsv(I_rgb);
    I_hsv3 = I_hsv(:,:,3); % Value
    a = size(I_hsv3); 
    [fea5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
    [fea8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
    [fea10,visual] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));
    
    fea5_rm(tree_counter,:) = fea5;
    fea8_rm(tree_counter,:) = fea8;
    fea10_rm(tree_counter,:) = fea10;
end

clear a tree_counter;

