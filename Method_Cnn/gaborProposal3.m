function [ bbox_all, scores_all ] = gaborProposal3( input_img )
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

I_intensityTH_smooth = imgaussfilt(I_hsv3,0.5);   
% Pre-process intensity image
%I_intensityTH_smooth = I_hsv3;

% Dulplicate computation : Optimized Later
wavelength_1 = [3];
wavelength_2 = [3 4];
wavelength_3 = [3 4 5];
wavelength_4 = [3 4 5 6];

porientation = [30 45 60];              % tobe accept orientation
norientation = [0 -30 -45 -60 90];      % tobe reject orientation

pBank1 = gabor(wavelength_1,porientation); % positive (Maximize Resp.)
nBank1 = gabor(wavelength_1,norientation); % negative (Minimize Resp.)

pBank2 = gabor(wavelength_2,porientation); % positive (Maximize Resp.)
nBank2 = gabor(wavelength_2,norientation); % negative (Minimize Resp.)

pBank3 = gabor(wavelength_3,porientation); % positive (Maximize Resp.)
nBank3 = gabor(wavelength_3,norientation); % negative (Minimize Resp.)

pBank4 = gabor(wavelength_4,porientation); % positive (Maximize Resp.)
nBank4 = gabor(wavelength_4,norientation); % negative (Minimize Resp.)

[pmag1, ~] = imgaborfilt(I_intensityTH_smooth,pBank1);
[nmag1, ~] = imgaborfilt(I_intensityTH_smooth,nBank1);

[pmag2, ~] = imgaborfilt(I_intensityTH_smooth,pBank2);
[nmag2, ~] = imgaborfilt(I_intensityTH_smooth,nBank2);

[pmag3, ~] = imgaborfilt(I_intensityTH_smooth,pBank3);
[nmag3, ~] = imgaborfilt(I_intensityTH_smooth,nBank3);

[pmag4, ~] = imgaborfilt(I_intensityTH_smooth,pBank4);
[nmag4, ~] = imgaborfilt(I_intensityTH_smooth,nBank4);


pSumMag1 = sum(pmag1,3);
nSumMag1 = sum(nmag1,3);

pSumMag2 = sum(pmag2,3);
nSumMag2 = sum(nmag2,3);

pSumMag3 = sum(pmag3,3);
nSumMag3 = sum(nmag3,3);

pSumMag4 = sum(pmag4,3);
nSumMag4 = sum(nmag4,3);

IsumMag1 = (pSumMag1 - nSumMag1).*I_tree;
IsumMag2 = (pSumMag2 - nSumMag2).*I_tree;
IsumMag3 = (pSumMag3 - nSumMag3).*I_tree;
IsumMag4 = (pSumMag4 - nSumMag4).*I_tree;

IsumMagBin1 = imbinarize(IsumMag1,0);
IsumMagBin2 = imbinarize(IsumMag2,0);
IsumMagBin3 = imbinarize(IsumMag3,0);
IsumMagBin4 = imbinarize(IsumMag4,0);

Iedge = edge(I_intensityTH_smooth,'Sobel','nothinning');
%Iedge = bwareaopen(Iedge,4,4); % remove small isolated point

Iedge_area_1 = Iedge.*IsumMagBin1;
Iedge_area_2 = Iedge.*IsumMagBin2;
Iedge_area_3 = Iedge.*IsumMagBin3;
Iedge_area_4 = Iedge.*IsumMagBin4;

Iedge_areaCC1 = bwconncomp(Iedge_area_1,8);
Iedge_areaCC2 = bwconncomp(Iedge_area_2,8);
Iedge_areaCC3 = bwconncomp(Iedge_area_3,8);
Iedge_areaCC4 = bwconncomp(Iedge_area_4,8);

stats_1 = regionprops(Iedge_areaCC1,'BoundingBox');
stats_2 = regionprops(Iedge_areaCC2,'BoundingBox');
stats_3 = regionprops(Iedge_areaCC3,'BoundingBox');
stats_4 = regionprops(Iedge_areaCC4,'BoundingBox');

bbox1(length(stats_1),4) = 0;
bbox2(length(stats_2),4) = 0;
bbox3(length(stats_3),4) = 0;
bbox4(length(stats_4),4) = 0;

scores_1(length(stats_1),1) = 0;
scores_2(length(stats_2),1) = 0;
scores_3(length(stats_3),1) = 0;
scores_4(length(stats_4),1) = 0;


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

bbox1 = fix(bbox1); % round toward zero
bbox_all = fix([bbox1;bbox2;bbox3;bbox4]);
scores_all =[scores_1;scores_2;scores_3;scores_4];

rowToClean = scores_all < 120; % less than area=16 windows will be removed

bbox_all( rowToClean,: ) = [];
scores_all( rowToClean ) = [];

%testIMG = 0.5*IsumMagBin + 0.5*I_hsv3;
end


%A(A(:, 5)== 0, :)= [] % remove any row by checking col 5

%a(ans', :) = []; % spcify ans' row to remove
