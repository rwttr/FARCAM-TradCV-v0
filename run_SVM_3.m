% 3-feature model

nRowPos = size(shapeF_Pos,1);
nRowNeg = size(shapeF_Neg,1);

nColShape = size(shapeF_Pos,2);
nColTFrr = size(textF_FRR_Pos,2);
nColTCmt = size(textF_CMT_Pos,2);
nColTHog = size(textF_HOG_Pos,2);

responseVec(nRowPos+nRowNeg,1) = zeros;
responseVec(1:nRowPos,1) = 1;
%--------------------------------------------------
% 11. Shape+ FRR + Co-Mat

sFCVec(nRowPos+nRowNeg, nColShape+nColTFrr+nColTCmt) = zeros;
sFCVec(1:nRowPos,:) = [shapeF_Pos textF_FRR_Pos textF_CMT_Pos];
sFCVec((nRowPos+1):end,:) = [shapeF_Neg textF_FRR_Neg textF_CMT_Neg];

SVM_sFC_linear = fitcsvm(sFCVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sFC_gaussian = fitcsvm(sFCVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sFC_poly = fitcsvm(sFCVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%---------------------------------------------------
% 12. Shape + FRR + HOG

sFHVec(nRowPos+nRowNeg, nColShape+nColTFrr+nColTHog) = zeros;
sFHVec(1:nRowPos,:) = [shapeF_Pos textF_FRR_Pos textF_HOG_Pos];
sFHVec((nRowPos+1):end,:) = [shapeF_Neg textF_FRR_Neg textF_HOG_Neg];

SVM_sFH_linear = fitcsvm(sFHVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sFH_gaussian = fitcsvm(sFHVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sFH_poly = fitcsvm(sFHVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%----------------------------------------------------
% 13. Shape + Co-Mat + HOG

sCHVec(nRowPos+nRowNeg, nColShape+nColTCmt+nColTHog) = zeros;
sCHVec(1:nRowPos,:) = [shapeF_Pos textF_CMT_Pos textF_HOG_Pos];
sCHVec((nRowPos+1):end,:) = [shapeF_Neg textF_CMT_Neg textF_HOG_Neg];

SVM_sCH_linear = fitcsvm(sCHVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_sCH_gaussian = fitcsvm(sCHVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_sCH_poly = fitcsvm(sCHVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%------------------------------------------------------
% 14. texture FRR + Co-Mat + HOG

fCHVec(nRowPos+nRowNeg, nColTFrr+nColTCmt+nColTHog) = zeros;
fCHVec(1:nRowPos,:) = [textF_FRR_Pos textF_CMT_Pos textF_HOG_Pos];
fCHVec((nRowPos+1):end,:) = [textF_FRR_Neg textF_CMT_Neg textF_HOG_Neg];

SVM_fCH_linear = fitcsvm(fCHVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);
SVM_fCH_gaussian = fitcsvm(fCHVec,responseVec,...
    'KernelFunction','gaussian','KernelScale','auto','Standardize',true);
SVM_fCH_poly = fitcsvm(fCHVec,responseVec,...
    'KernelFunction','polynomial','KernelScale','auto','Standardize',true);
%-----------------------------------------------------

clear nRowPos nRowNeg nColShape nColTFrr nColTCmt nColTHog responseVec
