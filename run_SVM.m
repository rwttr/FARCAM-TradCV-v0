% all-fearues model
%---------------------------------------
poly_order = 3;
nRowPos = size(shapeF_Pos,1);
nRowNeg = size(shapeF_Neg,1);

nColShape = size(shapeF_Pos,2);
nColTFrr = size(textF_FRR_Pos,2);
nColTCmt = size(textF_CMT_Pos,2);
nColTHog = size(textF_HOG_Pos,2);

responseVec(nRowPos+nRowNeg,1) = zeros;
responseVec(1:nRowPos,1) = 1;
%---------------------------------------
featureVec(nRowPos+nRowNeg, nColShape+nColTFrr+nColTCmt+nColTHog) = zeros;
featureVec(1:nRowPos,:) = ...
    [shapeF_Pos textF_FRR_Pos textF_CMT_Pos textF_HOG_Pos];
featureVec((nRowPos+1):end,:) = ...
    [shapeF_Neg textF_FRR_Neg textF_CMT_Neg textF_HOG_Neg];

SVM_4linear = fitcsvm(featureVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_4gaussian = fitcsvm(featureVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_4poly = fitcsvm(featureVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto',...
    'PolynomialOrder',poly_order,'Standardize',true);
%---------------------------------------

clear poly_order nRowPos nRowNeg nColShape nColTCmt nColTFrr nColTHog responseVec
clear featureVec
