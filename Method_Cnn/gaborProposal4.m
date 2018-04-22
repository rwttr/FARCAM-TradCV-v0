
%GABORPROPOSAL4
% V3 - optimized performance
function [ bbox_all, scores_all ] = gaborProposal4( input_img )
%GABORPROPOSAL3
%   Detailed explanation goes here
%       threshold tree
%       gabor run; positive going / negative going // stack lamda 4set
%       threshold gabor magnitude image
%       bbox all area rank by area

I_rgb = input_img;
I_hsv = rgb2hsv(I_rgb);
I_hsv3 = I_hsv(:,:,3); % Value

% Tree thresholding
th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level-0.01);
    % Single ROI :: remove smaller region (keep only tree region) 
noOfOne = ceil(sum(sum(I_hsv3_thresh))/3);
I_tree = bwareaopen(I_hsv3_thresh,noOfOne);
clear noOfOne

% Pre-process intensity image
I_intensityTH_smooth = I_hsv3;

%Iedge = edge(I_intensityTH_smooth_edge,'Canny');
Iedge = edge(I_intensityTH_smooth,'Sobel','nothinning');

lamda_1 = 3;
lamda_2 = 4;
lamda_3 = 5;
lamda_4 = 6;

porientation = [30 45 60];              % tobe accept orientation
norientation = [0 -30 -45 -60 90];      % tobe reject orientation

pBank1 = gabor(lamda_1,porientation); % positive (Maximize Resp.)
nBank1 = gabor(lamda_1,norientation); % negative (Minimize Resp.)

pBank2 = gabor(lamda_2,porientation); % positive (Maximize Resp.)
nBank2 = gabor(lamda_2,norientation); % negative (Minimize Resp.)

pBank3 = gabor(lamda_3,porientation); % positive (Maximize Resp.)
nBank3 = gabor(lamda_3,norientation); % negative (Minimize Resp.)

pBank4 = gabor(lamda_4,porientation); % positive (Maximize Resp.)
nBank4 = gabor(lamda_4,norientation); % negative (Minimize Resp.)

[pmag1, ~] = imgaborfilt(I_intensityTH_smooth,pBank1);
[nmag1, ~] = imgaborfilt(I_intensityTH_smooth,nBank1);
[pmag2, ~] = imgaborfilt(I_intensityTH_smooth,pBank2);
[nmag2, ~] = imgaborfilt(I_intensityTH_smooth,nBank2);
[pmag3, ~] = imgaborfilt(I_intensityTH_smooth,pBank3);
[nmag3, ~] = imgaborfilt(I_intensityTH_smooth,nBank3);
[pmag4, ~] = imgaborfilt(I_intensityTH_smooth,pBank4);
[nmag4, ~] = imgaborfilt(I_intensityTH_smooth,nBank4);

pSumMag3 = sum(pmag1,3);
nSumMag3 = sum(nmag1,3);
pSumMag4 = sum(pmag2,3);
nSumMag4 = sum(nmag2,3);
pSumMag5 = sum(pmag3,3);
nSumMag5 = sum(nmag3,3);
pSumMag6 = sum(pmag4,3);
nSumMag6 = sum(nmag4,3);

% combination: 3-34-4-45-5-56

I_3     = pSumMag3-nSumMag3;
I_34    = (pSumMag3+pSumMag4)-(nSumMag3+nSumMag4);
I_4     = pSumMag4-nSumMag4;
I_45    = (pSumMag4+pSumMag5)-(nSumMag4+nSumMag5);
I_5     = pSumMag5-nSumMag5;
I_56    = (pSumMag5+pSumMag6)-(nSumMag5+nSumMag6);

IsumMag1 = I_3 .*I_tree;
IsumMag2 = I_34.*I_tree;
IsumMag3 = I_4.*I_tree;
IsumMag4 = I_45.*I_tree;
IsumMag5 = I_5.*I_tree;
IsumMag6 = I_56.*I_tree;

IsumMagBin1 = imbinarize(IsumMag1,0);
IsumMagBin2 = imbinarize(IsumMag2,0);
IsumMagBin3 = imbinarize(IsumMag3,0);
IsumMagBin4 = imbinarize(IsumMag4,0);
IsumMagBin5 = imbinarize(IsumMag5,0);
IsumMagBin6 = imbinarize(IsumMag6,0);

Iedge_area_1 = Iedge.*IsumMagBin1;
Iedge_area_2 = Iedge.*IsumMagBin2;
Iedge_area_3 = Iedge.*IsumMagBin3;
Iedge_area_4 = Iedge.*IsumMagBin4;
Iedge_area_5 = Iedge.*IsumMagBin5;
Iedge_area_6 = Iedge.*IsumMagBin6;

Iedge_areaCC1 = bwconncomp(Iedge_area_1,8);
Iedge_areaCC2 = bwconncomp(Iedge_area_2,8);
Iedge_areaCC3 = bwconncomp(Iedge_area_3,8);
Iedge_areaCC4 = bwconncomp(Iedge_area_4,8);
Iedge_areaCC5 = bwconncomp(Iedge_area_5,8);
Iedge_areaCC6 = bwconncomp(Iedge_area_6,8);

stats_1 = regionprops(Iedge_areaCC1,'BoundingBox');
stats_2 = regionprops(Iedge_areaCC2,'BoundingBox');
stats_3 = regionprops(Iedge_areaCC3,'BoundingBox');
stats_4 = regionprops(Iedge_areaCC4,'BoundingBox');
stats_5 = regionprops(Iedge_areaCC5,'BoundingBox');
stats_6 = regionprops(Iedge_areaCC6,'BoundingBox');

bbox1(length(stats_1),4) = 0;
bbox2(length(stats_2),4) = 0;
bbox3(length(stats_3),4) = 0;
bbox4(length(stats_4),4) = 0;
bbox5(length(stats_5),4) = 0;
bbox6(length(stats_6),4) = 0;

scores_1(length(stats_1),1) = 0;
scores_2(length(stats_2),1) = 0;
scores_3(length(stats_3),1) = 0;
scores_4(length(stats_4),1) = 0;
scores_5(length(stats_5),1) = 0;
scores_6(length(stats_6),1) = 0;


for i = 1:length(stats_1)
    bbox1(i,1:4) = stats_1(i).BoundingBox;
    scores_1(i,1) = stats_1(i).BoundingBox(3)* stats_1(i).BoundingBox(4);
end

for i = 1:length(stats_2)
    bbox2(i,1:4) = stats_2(i).BoundingBox;
    scores_2(i,1) = stats_2(i).BoundingBox(3)* stats_2(i).BoundingBox(4);
end

for i = 1:length(stats_3)
    bbox3(i,1:4) = stats_3(i).BoundingBox;
    scores_3(i,1) = stats_3(i).BoundingBox(3)* stats_3(i).BoundingBox(4);
end

for i = 1:length(stats_4)
    bbox4(i,1:4) = stats_4(i).BoundingBox;
    scores_4(i,1) = stats_4(i).BoundingBox(3)* stats_4(i).BoundingBox(4);
end

for i = 1:length(stats_5)
    bbox5(i,1:4) = stats_5(i).BoundingBox;
    scores_5(i,1) = stats_5(i).BoundingBox(3)* stats_5(i).BoundingBox(4);
end

for i = 1:length(stats_6)
    bbox6(i,1:4) = stats_6(i).BoundingBox;
    scores_6(i,1) = stats_6(i).BoundingBox(3)* stats_6(i).BoundingBox(4);
end

bbox1 = fix(bbox1); % round toward zero
bbox_all = fix([bbox1;bbox2;bbox3;bbox4;bbox5;bbox6]);
scores_all =[scores_1;scores_2;scores_3;scores_4;scores_5;scores_6];

rowToClean = scores_all < 200; % windows area less than xx will be removed

bbox_all( rowToClean,: ) = [];
scores_all( rowToClean ) = [];

%testIMG = 0.5*IsumMagBin + 0.5*I_hsv3;
end

%A(A(:, 5)== 0, :)= [] % remove any row by checking col 5
%a(ans', :) = []; % spcify ans' row to remove




