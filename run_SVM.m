% all-fearues model
%---------------------------------------
nRowPos = size(shapeF_Pos,1);
nRowNeg = size(shapeF_Neg,1);

nColShape = size(shapeF_Pos,2);
nColTFrr = size(textF_FRR_Pos,2);
nColTCmt = size(textF_CMT_Pos,2);
nColTHog = size(textF_HOG_Pos,2);

responseVec(nRowPos+nRowNeg,1) = zeros;
responseVec(1:nRowPos,1) = 1;
%---------------------------------------
fearureVec(nRowPos+nRowNeg, nColShape+nColTFrr+nColTCmt+nColTHog) = zeros;
fearureVec(1:nRowPos,:) = ...
    [shapeF_Pos textF_FRR_Pos textF_CMT_Pos textF_HOG_Pos];
fearureVec((nRowPos+1):end,:) = ...
    [shapeF_Neg textF_FRR_Neg textF_CMT_Neg textF_HOG_Neg];

SVM_linear = fitcsvm(fearureVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_gaussian = fitcsvm(fearureVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_poly = fitcsvm(fearureVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%---------------------------------------

