% Single Feature model
responseVec(size(shapeF_Pos,1)+size(shapeF_Neg,1),1) = zeros;
responseVec(1:size(shapeF_Pos,1),1) = 1;
%------------------------------------------------------------------------
% 1. Shape

shapeFeatureVec(size(shapeF_Pos,1)+size(shapeF_Neg,1),...
    size(shapeF_Pos,2)) = zeros;
shapeFeatureVec(1:size(shapeF_Pos,1),:) = shapeF_Pos;
shapeFeatureVec((size(shapeF_Pos,1)+1):end,:) = shapeF_Neg;

SVM_Shape_linear = fitcsvm(shapeFeatureVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_Shape_gauss = fitcsvm(shapeFeatureVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_Shape_poly = fitcsvm(shapeFeatureVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%------------------------------------------------------------------------
% 2. Texture Fourier

tFrrFeatureVec(size(textF_FRR_Pos,1)+size(textF_FRR_Neg,1),... 
    size(textF_FRR_Pos,2)) = zeros;
tFrrFeatureVec(1:size(textF_FRR_Pos,1),:) = textF_FRR_Pos;
tFrrFeatureVec((size(textF_FRR_Pos,1)+1):end,:) = textF_FRR_Neg;

SVM_tFrr_linear = fitcsvm(tFrrFeatureVec,responseVec,... 
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tFrr_gauss = fitcsvm(tFrrFeatureVec,responseVec,... 
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tFrr_poly = fitcsvm(tFrrFeatureVec,responseVec,... 
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%------------------------------------------------------------------------
% 3. Texture Co-occurrence Matrix

tCmtFeatureVec(size(textF_CMT_Pos,1)+size(textF_CMT_Neg,1),... 
    size(textF_CMT_Pos,2)) = zeros;
tCmtFeatureVec(1:size(textF_CMT_Pos,1),:) = textF_CMT_Pos;
tCmtFeatureVec((size(textF_CMT_Pos,1)+1):end,:) = textF_CMT_Neg;

SVM_tCmt_linear = fitcsvm(tCmtFeatureVec,responseVec,... 
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tCmt_gauss = fitcsvm(tCmtFeatureVec,responseVec,... 
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tCmt_poly = fitcsvm(tCmtFeatureVec,responseVec,... 
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%------------------------------------------------------------------------
% 4 Texture HOG

tHogFeatureVec(size(textF_HOG_Pos,1)+size(textF_HOG_Neg,1),... 
    size(textF_HOG_Pos,2)) = zeros;
tHogFeatureVec(1:size(textF_HOG_Pos,1),:) = textF_HOG_Pos;
tHogFeatureVec((size(textF_HOG_Pos,1)+1):end,:) = textF_HOG_Neg;

SVM_tHog_linear = fitcsvm(tHogFeatureVec,responseVec,... 
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_tHog_gauss = fitcsvm(tHogFeatureVec,responseVec,... 
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_tHog_poly = fitcsvm(tHogFeatureVec,responseVec,... 
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%------------------------------------------------------------------------

