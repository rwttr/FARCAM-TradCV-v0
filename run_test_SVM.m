% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG
nRowPos = size(test_shF_Pos,1);
nRowNeg = size(test_shF_Neg,1);
nCol = size(test_shF_Pos,2)+size(test_teF_FRR_Pos,2)+...
        size(test_teF_CMT_Pos,2)+size(test_teF_HOG_Pos,2);

Y = test_responseVec;    
X(nRowPos+nRowNeg,nCol) = zeros; %test feature row vector
X(1:nRowPos,:) = ...
    [test_shF_Pos test_teF_FRR_Pos test_teF_CMT_Pos test_teF_HOG_Pos];
X((nRowPos+1):end,:) = ...
    [test_shF_Neg test_teF_FRR_Neg test_teF_CMT_Neg test_teF_HOG_Neg];
    
[label_L,score_L] = predict(SVM_4linear,X);
[label_G,score_G] = predict(SVM_4gaussian,X);
[label_P,score_P] = predict(SVM_4poly,X);

%True positive (Accept true samples):raw value
sum(label_L.*Y)
sum(label_G.*Y)
sum(label_P.*Y)

%True Negaitive (Reject false samples):raw value
sum(imcomplement(label_L).*imcomplement(Y));
sum(imcomplement(label_G).*imcomplement(Y));
sum(imcomplement(label_P).*imcomplement(Y));

%False Positive (Accept false samples):raw value
sum(label_L.*imcomplement(Y));
sum(label_G.*imcomplement(Y));
sum(label_P.*imcomplement(Y));

%False Negative (Reject true samples):raw value
sum(imcomplement(label_L).*Y);
sum(imcomplement(label_G).*Y);
sum(imcomplement(label_P).*Y);
