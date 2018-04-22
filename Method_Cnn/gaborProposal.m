function [ bbox, scores, testIMG ] = gaborProposal( input_img )
%GABORPROPOSAL Summary of this function goes here
%   Detailed explanation goes here
%       threshold tree
%       gabor run; positive going / negative going
%       threshold gabor magnitude image
%       bbox all area rank by??

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

%I_intensityTH_smooth = imgaussfilt(I_hsv3,0.25);   
% Pre-process intensity image
I_intensityTH_smooth = I_hsv3;

wavelength = [3 4 5 6];
porientation = [30 45 60];        % tobe accept orientation
norientation = [0 -30 -45 -60 90];      % tobe reject orientation
pBank = gabor(wavelength,porientation); % positive (Maximize Resp.)
nBank = gabor(wavelength,norientation); % negative (Minimize Resp.)

[pmag, ~] = imgaborfilt(I_intensityTH_smooth,pBank);
[nmag, ~] = imgaborfilt(I_intensityTH_smooth,nBank);

pSumMag = sum(pmag,3);
nSumMag = sum(nmag,3);

IsumMag = (pSumMag) - nSumMag;
IsumMag = IsumMag .* I_tree;

IsumMagBin = imbinarize(IsumMag,0); % suspected area ;


Iedge = edge(I_intensityTH_smooth,'Sobel','nothinning');
Iedge_area = Iedge.*IsumMagBin;
Iedge_area = bwareaopen(Iedge_area,4,4);
Iedge_areaCC = bwconncomp(Iedge_area,8);

stats = regionprops(Iedge_areaCC,'BoundingBox');
bbox(length(stats),4) = 0;
scores(length(stats),1) = 0;

for i = 1:length(stats)
    bbox(i,1:4) = stats(i).BoundingBox;
    scores(i,1) = stats(i).BoundingBox(3)* stats(i).BoundingBox(4);
end

bbox = fix(bbox); % round toward zero
testIMG = 0.5*IsumMagBin + 0.5*I_hsv3;
testIMG = 0.5*Iedge_area + 0.5*I_hsv3;
end

