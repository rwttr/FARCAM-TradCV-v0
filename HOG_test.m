
% Extract test HOG feature
% 16 positive samples(1), 14 negative samples(0)
TESTIMGPATH = 'C:\Users\Rattachai\Desktop\testIMG1\test';
ENDDING = '.jpg';

%before loop observe matrix dimension for varr declaration
sample_counter = 1; %start
TESTIMGPATH = strcat(TESTIMGPATH,int2str(sample_counter),ENDDING);
I_rgb = imread(TESTIMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv3 = I_hsv(:,:,3); % Value

ntestSample = 30; % no of test sample

testResponseVec(1:ntestSample,1) = 0;
testResponseVec(1:16,1) = 1; %16 true sample

a = size(I_hsv3); % image size
[test_fea5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
[test_fea8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
[test_fea10,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));


nCol_test_fea5 = size(test_fea5,2);
nCol_test_fea8 = size(test_fea8,2);
nCol_test_fea10 = size(test_fea10,2);

% rm = row matrix
test_fea5_rm(ntestSample,nCol_test_fea5) = zeros; 
test_fea8_rm(ntestSample,nCol_test_fea8) = zeros;
test_fea10_rm(ntestSample,nCol_test_fea10) = zeros;

test_fea5_rm(1,:) = test_fea5;
test_fea8_rm(1,:) = test_fea8;
test_fea10_rm(1,:) = test_fea10;

for sample_counter= 2:ntestSample
    TESTIMGPATH = 'C:\Users\Rattachai\Desktop\testIMG1\test';
    TESTIMGPATH = strcat(TESTIMGPATH,int2str(sample_counter),ENDDING);
    I_rgb = imread(TESTIMGPATH);
    I_hsv = rgb2hsv(I_rgb);
    I_hsv3 = I_hsv(:,:,3); % Value
    a = size(I_hsv3); 
    [test_fea5,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/5));
    [test_fea8,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/8));
    [test_fea10,~] = extractHOGFeatures(I_hsv3,'CellSize',floor(a/10));
    
    test_fea5_rm(sample_counter,:) = test_fea5;
    test_fea8_rm(sample_counter,:) = test_fea8;
    test_fea10_rm(sample_counter,:) = test_fea10;
end

clear a sample_counter;


%{
[predictedLabels10, scores] = predict(SVMModel10, test_fea10_RowMat);
confMat8 = confusionmat(testResponse, predictedLabels10);
%}

