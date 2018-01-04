%load segmented patch into cell
%Positive Sample
%//////////////////////////////////////////////////////////////////////////////
%no of sample
NO_SAMPLE = 20;
START_FILE_NO = 31;
IMGPATH_BW = 'C:\Users\Rattachai\Desktop\Matlab_exp\Segmented Data\POS_bw\';
IMGPATH_HSV3 = 'C:\Users\Rattachai\Desktop\Matlab_exp\Segmented Data\POS_hsv3\';

pos_bw_store{NO_SAMPLE,1} = zeros;
pos_hsv3_store{NO_SAMPLE,1} = zeros;

for i= 1:NO_SAMPLE
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_POS_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_POS_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    pos_bw_store{i,1} = load(IMG_dir_bw);
    pos_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

% extract shape feature
% size for initialize 
szShape = extShapeFeature(pos_bw_store{1}.patch_bw_POS);
[szTextFrr, szTextCoMat,szTextHOG] = ...
    extTextureFeature(pos_hsv3_store{1}.patch_hsv3_POS);

test_shF_Pos(NO_SAMPLE,size(szShape,2)) = zeros;
test_teF_FRR_Pos(NO_SAMPLE,size(szTextFrr,2)) =zeros;
test_teF_CMT_Pos(NO_SAMPLE,size(szTextCoMat,2)) =zeros;
test_teF_HOG_Pos(NO_SAMPLE,size(szTextHOG,2)) =zeros;


for i = 1:NO_SAMPLE
    test_shF_Pos(i,:) = extShapeFeature(pos_bw_store{i}.patch_bw_POS);
    [test_teF_FRR_Pos(i,:), test_teF_CMT_Pos(i,:), test_teF_HOG_Pos(i,:)] = ...
        extTextureFeature(pos_hsv3_store{i}.patch_hsv3_POS);
    
end

%//////////////////////////////////////////////////////////////////////////
% Negative Sample
IMGPATH_BW = 'C:\Users\Rattachai\Desktop\Matlab_exp\Segmented Data\NEG_bw\';
IMGPATH_HSV3 = 'C:\Users\Rattachai\Desktop\Matlab_exp\Segmented Data\NEG_hsv3\';

EACHFILE = 4;

neg_bw_store{NO_SAMPLE,1} = zeros;
neg_hsv3_store{NO_SAMPLE,1} = zeros;

for i= 1:NO_SAMPLE
    IMG_dir_bw = strcat(IMGPATH_BW,'patch_bw_NEG_', ...
        int2str(i+START_FILE_NO-1),'.mat');
    IMG_dir_hsv3 = strcat(IMGPATH_HSV3,'patch_hsv3_NEG_', ... 
        int2str(i+START_FILE_NO-1),'.mat');
    neg_bw_store{i,1} = load(IMG_dir_bw);
    neg_hsv3_store{i,1} = load(IMG_dir_hsv3);
end

test_shF_Neg(NO_SAMPLE*EACHFILE,size(szShape,2)) = zeros;
test_teF_FRR_Neg(NO_SAMPLE*EACHFILE,size(szTextFrr,2)) =zeros;
test_teF_CMT_Neg(NO_SAMPLE*EACHFILE,size(szTextCoMat,2)) =zeros;
test_teF_HOG_Neg(NO_SAMPLE*EACHFILE,size(szTextHOG,2)) =zeros;
clear szShape szTextFrr szTextCoMat szTextHOG

j = 1;
for i = 1:NO_SAMPLE
    j = 1+(4*(i-1));
    test_shF_Neg(j,:) = extShapeFeature(neg_bw_store{i}.patch_bw_NEG{1});
    test_shF_Neg(j+1,:) = extShapeFeature(neg_bw_store{i}.patch_bw_NEG{2});
    test_shF_Neg(j+2,:) = extShapeFeature(neg_bw_store{i}.patch_bw_NEG{3});
    test_shF_Neg(j+3,:) = extShapeFeature(neg_bw_store{i}.patch_bw_NEG{4});
    
    [test_teF_FRR_Neg(j,:), test_teF_CMT_Neg(j,:), test_teF_HOG_Neg(j,:)] = ...
        extTextureFeature(neg_hsv3_store{i}.patch_hsv3_NEG{1});
    [test_teF_FRR_Neg(j+1,:), test_teF_CMT_Neg(j+1,:), test_teF_HOG_Neg(j+1,:)] = ...
        extTextureFeature(neg_hsv3_store{i}.patch_hsv3_NEG{2});
    [test_teF_FRR_Neg(j+2,:), test_teF_CMT_Neg(j+2,:), test_teF_HOG_Neg(j+2,:)] = ...
        extTextureFeature(neg_hsv3_store{i}.patch_hsv3_NEG{3});
    [test_teF_FRR_Neg(j+3,:), test_teF_CMT_Neg(j+3,:), test_teF_HOG_Neg(j+3,:)] = ...
        extTextureFeature(neg_hsv3_store{i}.patch_hsv3_NEG{4});
       
end


test_responseVec(1:NO_SAMPLE*EACHFILE,1) = zeros;
test_responseVec(1:NO_SAMPLE,1) = 1;

clear i j IMGPATH_BW IMGPATH_HSV3 EACHFILE NO_SAMPLE neg_bw_store ...
    pos_hsv3_store neg_bw_store neg_hsv3_store IMG_dir_bw IMG_dir_hsv3 ...
    pos_bw_store START_FILE_NO

