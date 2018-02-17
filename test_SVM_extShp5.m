% response Vector = test_responseVec
% all-feature model shapeF:textFRR:textCMT:textHOG

%load segmented patch into cell



%Positive Sample
%/////////////////////////////////////////////////////////////////////////


% trained model
%[SVM_model,~] = train_SVM_extShp5();


NO_SAMPLE_test = 20; %no of sample
START_FILE_NO = 31;
IMGPATH_BW = 'Seg2 Data\POS_bw\';
IMGPATH_HSV3 = 'Seg2 Data\POS_hsv3\';

pos_bw_store{NO_SAMPLE_test,1} = zeros;
pos_hsv3_store{NO_SAMPLE_test,1} = zeros;

for i= 1:NO_SAMPLE_test
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_POS_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_POS_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    
    pos_bw_store{i,1} = load(IMG_dir_bw);
    pos_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

% extract shape feature
% size for initialize 
szShape = extShp5Gabor(pos_hsv3_store{1}.patch_hsv3_POS{1},...
    pos_bw_store{1}.patch_bw_POS{1});
test_fea_Pos(NO_SAMPLE_test,length(szShape)) = zeros;

for i = 1:NO_SAMPLE_test
    test_fea_Pos(i,:) = extShp5Gabor(pos_hsv3_store{i}.patch_hsv3_POS{1},...
        pos_bw_store{i}.patch_bw_POS{1});        
end

%//////////////////////////////////////////////////////////////////////////
% Negative Sample
IMGPATH_BW = 'Seg2 Data\NEG_bw\';
IMGPATH_HSV3 = 'Seg2 Data\NEG_hsv3\';

EACHFILE = 4;

neg_bw_store{NO_SAMPLE_test,1} = zeros;
neg_hsv3_store{NO_SAMPLE_test,1} = zeros;

for i= 1:NO_SAMPLE_test
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_NEG_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_NEG_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    neg_bw_store{i,1} = load(IMG_dir_bw);
    neg_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

test_fea_Neg(NO_SAMPLE_test*EACHFILE,size(szShape,2)) = zeros;

j = 1;
for i = 1:NO_SAMPLE_test
    j = 1+(4*(i-1));
    test_fea_Neg(j,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{1},...
        neg_bw_store{i}.patch_bw_NEG{1});
    test_fea_Neg(j+1,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{2},...
        neg_bw_store{i}.patch_bw_NEG{2});
    test_fea_Neg(j+2,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{3},...
        neg_bw_store{i}.patch_bw_NEG{3});
    test_fea_Neg(j+3,:) = extShp5Gabor(neg_hsv3_store{i}.patch_hsv3_NEG{4},...
        neg_bw_store{i}.patch_bw_NEG{4});
           
end


test_responseVec(1:(NO_SAMPLE_test*EACHFILE)+NO_SAMPLE_test,1) = zeros;
test_responseVec(1:NO_SAMPLE_test,1) = 1;



%----------------------------------------------------------------------------------


disp('---------------------------------------------------');
disp('     Single Feature(Shape) SVM Model');
disp('---------------------------------------------------');
% test vector size
nRowPos = size(test_fea_Pos,1);
nRowNeg = size(test_fea_Neg,1);
nColShape =  size(test_fea_Pos,2);


Y = test_responseVec; % from run_extTestFeature

XShape(nRowPos+nRowNeg,nColShape) = zeros; %test feature row vector
XShape(1:nRowPos,:) = test_fea_Pos;
XShape((nRowPos+1):end,:) = test_fea_Neg;
    
[label_shape_L,~] = predict(SVM_model,XShape);






%------------------------------------------------------------
%Test Score part - for each SVM Kernel
%------------------------------------------------------------
%True positive (Accept true samples):raw value
Tp_L = sum(label_shape_L.*Y);

%True Negaitive (Reject false samples):raw value
Tn_L = sum(imcomplement(label_shape_L).*imcomplement(Y));

%False Positive (Accept false samples):raw value //real data is wrong but model
Fp_L = sum(label_shape_L.*imcomplement(Y));

%False Negative (Reject true samples):raw value
Fn_L = sum(imcomplement(label_shape_L).*Y);     % real data is true but model reject

% Accuracy(ACC) = (Tp+Tn)/(Tp+Tn+Fp+Fn)
acc_linear =  (Tp_L+Tn_L)/(Tp_L +Tn_L +Fp_L +Fn_L);

% Precision (positive predictive value (PPV)) = Tp/(Tp+Fp)
ppv_linear = Tp_L/(Tp_L+Fp_L);

% Sensitivity, Recall, HitRate, True Positive rate = Tp/(Tp+Fn)
sen_linear = Tp_L/(Tp_L+Fn_L);

% specificity or true negative rate (TNR) = Tn/(Tn+Fp)
spci_linear = Tn_L/(Tn_L+Fp_L);


% Display Section
disp('    Linear SVM Kernel: ');
disp('Accuracy / Precision / Sensitivity / Specificity');
disp([acc_linear ppv_linear sen_linear spci_linear]);
disp('---------------------------------------------------');


   

