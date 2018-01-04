
TAPPATH = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_nontap\t';
%LIGHT_LV = '_1.jpg';

%insideloop
sample_counter = 1;
TAPPATH = strcat(TAPPATH,int2str(sample_counter));
I_rgb = imread(TAPPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv3 = I_hsv(:,:,3); % Value

a = size(I_hsv3);  
[feaNon5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
[feaNon8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
[feaNon10,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));

%{
figure;
subplot(1,2,1);
imshowpair(I_rgb,I_hsv3,'montage');
subplot(1,2,2);
imshow(I_hsv3); 
hold on
plot(visualHOG5);

%}

nSample = 40; % no of data 
nCol_feaNon5 = size(feaNon5,2);
nCol_feaNon8 = size(feaNon8,2);
nCol_feaNon10 = size(feaNon10,2);

feaNon5_RowMat(nSample,nCol_feaNon5) = zeros;
feaNon8_RowMat(nSample,nCol_feaNon8) = zeros;
feaNon10_RowMat(nSample,nCol_feaNon10) = zeros;

feaNon5_RowMat(1,:) = feaNon5;
feaNon8_RowMat(1,:) = feaNon8;
feaNon10_RowMat(1,:) = feaNon10;

for sample_counter=2:40
    TAPPATH = strcat(TAPPATH,int2str(sample_counter),LIGHT_LV);
    I_rgb = imread(TAPPATH);
    I_hsv = rgb2hsv(I_rgb);
    I_hsv3 = I_hsv(:,:,3); % Value

    [feaNon5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
    [feaNon8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
    [feaNon10,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));
    
    feaNon5_RowMat(sample_counter,:) = feaNon5;
    feaNon8_RowMat(sample_counter,:) = feaNon8;
    feaNon10_RowMat(sample_counter,:) = feaNon10;
end
clear [visualN5 visualN8 visualN10];
