function [SVM_Model,tExtract] = train_SVM_extShp4

% Training Part
NO_SAMPLE = 30;
EACHFILE = 4; %negative sample per file

IMGPATH_POS_BW = 'Seg2 Data\POS_bw\';
IMGPATH_NEG_BW = 'Seg2 Data\NEG_bw\';


%load image patch from files store in pos_bw_store/pos_hsv3_store column cell
pos_bw_store{NO_SAMPLE,1} = zeros;
neg_bw_store{NO_SAMPLE,1} = zeros;


for i= 1:NO_SAMPLE
    IMG_dir_pos = strcat(IMGPATH_POS_BW,'patch_bw_POS_', ...
        int2str(i),'.mat');
    IMG_dir_neg = strcat(IMGPATH_NEG_BW,'patch_bw_NEG_', ... 
        int2str(i),'.mat');
    
    
    pos_bw_store{i,1} = load(IMG_dir_pos);       
    neg_bw_store{i,1} = load(IMG_dir_neg);
            
end

tic;  %Timer Start
%   Size for initialize 
szShape = extShape4(pos_bw_store{1}.patch_bw_POS{1});
fea_POS(NO_SAMPLE,length(szShape)) = zeros;
fea_NEG(NO_SAMPLE*EACHFILE,length(szShape)) = zeros;

j = 1;
accumTime = 0;
clear i;
for i = 1:NO_SAMPLE    
    tic;
    fea_POS(i,:) = extShape4(pos_bw_store{i}.patch_bw_POS{1}); 
    
    j = 1+(4*(i-1));
    fea_NEG(j,:) = extShape4(neg_bw_store{i}.patch_bw_NEG{1});
    fea_NEG(j+1,:) = extShape4(neg_bw_store{i}.patch_bw_NEG{2});
    fea_NEG(j+2,:) = extShape4(neg_bw_store{i}.patch_bw_NEG{3});
    fea_NEG(j+3,:) = extShape4(neg_bw_store{i}.patch_bw_NEG{4});
end

tExtract = accumTime/NO_SAMPLE; % timer stop (feature extract)

trainFeaVec(size(fea_POS,1)+size(fea_NEG,1),...
    size(fea_POS,2)) = zeros;
trainFeaVec(1:size(fea_POS,1),:) = fea_POS;
trainFeaVec((size(fea_POS,1)+1):end,:) = fea_NEG;

responseVec(size(fea_POS,1)+size(fea_NEG,1),1) = zeros;
responseVec(1:size(fea_POS,1),1) = 1;

SVM_Model = fitcsvm(trainFeaVec,responseVec,...
    'KernelFunction','linear','KernelScale','auto','Standardize',true);

end




