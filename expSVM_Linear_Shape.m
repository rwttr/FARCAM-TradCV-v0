function [SVM_Model,tFeatureExtract] = expSVM_Linear_Shape(nbin, maSize)

% Training Part
NO_SAMPLE = 30;
EACHFILE = 4; %negative sample per file

IMGPATH_POS_BW = 'Segmented Data\POS_bw\';
IMGPATH_POS_HSV3 = 'Segmented Data\POS_hsv3\';
IMGPATH_NEG_BW = 'Segmented Data\NEG_bw\';
IMGPATH_NEG_HSV3 = 'Segmented Data\NEG_hsv3\';

%load image patch from files store in pos_bw_store/pos_hsv3_store column cell
pos_bw_store{NO_SAMPLE,1} = zeros;
pos_hsv3_store{NO_SAMPLE,1} = zeros;
neg_bw_store{NO_SAMPLE,1} = zeros;
neg_hsv3_store{NO_SAMPLE,1} = zeros;

for i= 1:NO_SAMPLE
    IMG_dir_pos_bw = strcat(IMGPATH_POS_BW,'patch_bw_POS_', ...
        int2str(i),'.mat');
    IMG_dir_pos_hsv3 = strcat(IMGPATH_POS_HSV3,'patch_hsv3_POS_', ... 
        int2str(i),'.mat');
    IMG_dir_neg_bw = strcat(IMGPATH_NEG_BW,'patch_bw_NEG_', ...
        int2str(i),'.mat');
    IMG_dir_neg_hsv3 = strcat(IMGPATH_NEG_HSV3,'patch_hsv3_NEG_', ... 
        int2str(i),'.mat');
    
    pos_bw_store{i,1} = load(IMG_dir_pos_bw);
    pos_hsv3_store{i,1} = load(IMG_dir_pos_hsv3);    
    neg_bw_store{i,1} = load(IMG_dir_neg_bw);
    neg_hsv3_store{i,1} = load(IMG_dir_neg_hsv3);           
end

tic;  %Timer Start
%   Size for initialize 
szShape = extShape2(pos_bw_store{1}.patch_bw_POS,nbin,maSize);
shapeF_POS(NO_SAMPLE,size(szShape,2)) = zeros;
shapeF_NEG(NO_SAMPLE*EACHFILE,size(szShape,2)) = zeros;

j = 1;
accumTime = 0;
clear i;
for i = 1:NO_SAMPLE    
    tic;
    shapeF_POS(i,:) = extShape2(pos_bw_store{i}.patch_bw_POS,nbin,maSize); 
    accumTime = accumTime+toc;
    j = 1+(4*(i-1));
    shapeF_NEG(j,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{1},nbin,maSize);
    shapeF_NEG(j+1,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{2},nbin,maSize);
    shapeF_NEG(j+2,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{3},nbin,maSize);
    shapeF_NEG(j+3,:) = extShape2(neg_bw_store{i}.patch_bw_NEG{4},nbin,maSize);
end

tFeatureExtract = accumTime/NO_SAMPLE; % timer stop (feature extract)

shapeFeatureVec(size(shapeF_POS,1)+size(shapeF_NEG,1),...
    size(shapeF_POS,2)) = zeros;
shapeFeatureVec(1:size(shapeF_POS,1),:) = shapeF_POS;
shapeFeatureVec((size(shapeF_POS,1)+1):end,:) = shapeF_NEG;

responseVec(size(shapeF_POS,1)+size(shapeF_NEG,1),1) = zeros;
responseVec(1:size(shapeF_POS,1),1) = 1;

SVM_Model = fitcsvm(shapeFeatureVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);

end




