% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG
run_extFeature;
run_extTestFeature;
run_SVM;

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

%------------------------------------------------------------
%Test Score part - for each SVM Kernel
%------------------------------------------------------------
%True positive (Accept true samples):raw value
Tp_4L = sum(label_L.*Y);
Tp_4G = sum(label_G.*Y);
Tp_4P = sum(label_P.*Y);

%True Negaitive (Reject false samples):raw value
Tn_4L = sum(imcomplement(label_L).*imcomplement(Y));
Tn_4G = sum(imcomplement(label_G).*imcomplement(Y));
Tn_4P = sum(imcomplement(label_P).*imcomplement(Y));

%False Positive (Accept false samples):raw value
Fp_4L = sum(label_L.*imcomplement(Y));
Fp_4G = sum(label_G.*imcomplement(Y));
Fp_4P = sum(label_P.*imcomplement(Y));

%False Negative (Reject true samples):raw value
Fn_4L = sum(imcomplement(label_L).*Y);
Fn_4G = sum(imcomplement(label_G).*Y);
Fn_4P = sum(imcomplement(label_P).*Y);

% Accuracy(ACC) = (Tp+Tn)/(Tp+Tn+Fp+Fn)
acc_linear =  (Tp_4L+Tn_4L)/(Tp_4L +Tn_4L +Fp_4L +Fn_4L);
acc_gaussian = (Tp_4G+Tn_4G)/(Tp_4G +Tn_4G +Fp_4G +Fn_4G);
acc_polynomial = (Tp_4P+Tn_4P)/(Tp_4P +Tn_4P +Fp_4P +Fn_4P);

% Precision (positive predictive value (PPV)) = Tp/(Tp+Fp)
ppv_linear = Tp_4L/(Tp_4L+Fp_4L);
ppv_gaussian = Tp_4G/(Tp_4G+Fp_4G);
ppv_polynomial = Tp_4P/(Tp_4P+Fp_4P);

% Sensitivity, Recall, HitRate, True Positive rate = Tp/(Tp+Fn)
sen_linear = Tp_4L/(Tp_4L+Fn_4L);
sen_gaussian = Tp_4G/(Tp_4G+Fn_4G);
sen_polynomial = Tp_4P/(Tp_4P+Fn_4P);

% specificity or true negative rate (TNR) = Tn/(Tn+Fp)
spci_linear = Tn_4L/(Tn_4L+Fp_4L);
spci_gaussian = Tn_4G/(Tn_4G+Fp_4G);
spci_polynomial = Tn_4P/(Tn_4P+Fp_4P);

% Display Section
disp('    Linear SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_linear ppv_linear sen_linear spci_linear]);
disp('---------------------------------------------------');

disp('    Gaussian SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_gaussian ppv_gaussian sen_gaussian spci_gaussian]);
disp('---------------------------------------------------');

disp('    Polynomial(3rd order) SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_polynomial ppv_polynomial sen_polynomial spci_polynomial]);
disp('---------------------------------------------------');
    
