
% Data From HOG Tap
% X =  feaTap5_RowMat
% y = responseVec

SVMModel5 = fitcsvm(fea5_rm,responseVec,'KernelFunction','rbf',...
    'KernelScale','auto','Standardize',true);
SVMModel8 = fitcsvm(test_fea8_rm,testresponseVec,'KernelFunction','rbf',...
    'KernelScale','auto','Standardize',true);
SVMModel10 = fitcsvm(fea10_rm,responseVec,'KernelFunction','rbf',...
    'KernelScale','auto','Standardize',true,'OutlierFraction',0.00);

% For one-class learning, the software finds an appropriate bias term
% such that outlierfraction of the observations in the training set
% have negative scores.

[class_result10,score10] = predict(SVMModel10,test_fea10_rm);



