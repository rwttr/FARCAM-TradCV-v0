% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG
run_extFeature;
run_extTestFeature;
run_SVM_1;
disp('---------------------------------------------------');
disp('   Single Feature(Texture:Fourier Transform) SVM Model');
disp('---------------------------------------------------');
% test vector size
nRowPos = size(test_shF_Pos,1);
nRowNeg = size(test_shF_Neg,1);
nColShape =  size(test_shF_Pos,2);
nCol_T_FRR = size(test_teF_FRR_Pos,2);
nCol_T_CMT = size(test_teF_CMT_Pos,2);
nCol_T_HOG = size(test_teF_HOG_Pos,2);

Y = test_responseVec; % from run_extTestFeature

XShape(nRowPos+nRowNeg,nCol_T_FRR) = zeros; %test feature row vector
XShape(1:nRowPos,:) = test_teF_FRR_Pos;
XShape((nRowPos+1):end,:) = test_teF_FRR_Neg;
    
[label_shape_L,~] = predict(SVM_tFrr_linear,XShape);
[label_shape_G,~] = predict(SVM_tFrr_gauss,XShape);
[label_shape_P,~] = predict(SVM_tFrr_poly,XShape);

%------------------------------------------------------------
%Test Score part - for each SVM Kernel
%------------------------------------------------------------
%True positive (Accept true samples):raw value
Tp_L = sum(label_shape_L.*Y);
Tp_G = sum(label_shape_G.*Y);
Tp_P = sum(label_shape_P.*Y);

%True Negaitive (Reject false samples):raw value
Tn_L = sum(imcomplement(label_shape_L).*imcomplement(Y));
Tn_G = sum(imcomplement(label_shape_G).*imcomplement(Y));
Tn_P = sum(imcomplement(label_shape_P).*imcomplement(Y));

%False Positive (Accept false samples):raw value
Fp_L = sum(label_shape_L.*imcomplement(Y));
Fp_G = sum(label_shape_G.*imcomplement(Y));
Fp_P = sum(label_shape_P.*imcomplement(Y));

%False Negative (Reject true samples):raw value
Fn_L = sum(imcomplement(label_shape_L).*Y);
Fn_G = sum(imcomplement(label_shape_G).*Y);
Fn_P = sum(imcomplement(label_shape_P).*Y);

% Accuracy(ACC) = (Tp+Tn)/(Tp+Tn+Fp+Fn)
acc_linear =  (Tp_L+Tn_L)/(Tp_L +Tn_L +Fp_L +Fn_L);
acc_gaussian = (Tp_G+Tn_G)/(Tp_G +Tn_G +Fp_G +Fn_G);
acc_polynomial = (Tp_P+Tn_P)/(Tp_P +Tn_P +Fp_P +Fn_P);

% Precision (positive predictive value (PPV)) = Tp/(Tp+Fp)
ppv_linear = Tp_L/(Tp_L+Fp_L);
ppv_gaussian = Tp_G/(Tp_G+Fp_G);
ppv_polynomial = Tp_P/(Tp_P+Fp_P);

% Sensitivity, Recall, HitRate, True Positive rate = Tp/(Tp+Fn)
sen_linear = Tp_L/(Tp_L+Fn_L);
sen_gaussian = Tp_G/(Tp_G+Fn_G);
sen_polynomial = Tp_P/(Tp_P+Fn_P);

% specificity or true negative rate (TNR) = Tn/(Tn+Fp)
spci_linear = Tn_L/(Tn_L+Fp_L);
spci_gaussian = Tn_G/(Tn_G+Fp_G);
spci_polynomial = Tn_P/(Tn_P+Fp_P);

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
   

