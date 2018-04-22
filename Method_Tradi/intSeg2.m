%function [I_tree,I_magEdge,I_result] = intSeg2( IMG_NO, IMG_DIR )
% Remove color factor for segmentation
% 1
%Threshold intensity channel
IMG_NO = 65;
IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),'.jpg');

%test for hsv color model
I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = imgaussfilt(I_hsv(:,:,1),0.2);
I_hsv2 = I_hsv(:,:,2);
I_hsv3 = I_hsv(:,:,3); % Value

% test for lab color model
I_lab = rgb2lab(I_rgb,'WhitePoint','e');
I_labL = I_lab(:,:,1);
I_labA = I_lab(:,:,2);
I_labB = I_lab(:,:,3);


%th_level = graythresh(I_hsv3);  % otsu threshhold 

th_level = 20;                  % staic threshold
% segemnt for tree
I_intensity_thresh = imbinarize(I_labL,th_level);

noOfOne = ceil(sum(sum(I_intensity_thresh))/3);
I_tree = bwareaopen(I_intensity_thresh,noOfOne);
%imshow(I_tree);

I_intensityTH_smooth = imgaussfilt(I_labL,0.20);

% Gabor for Segmentation
wavelength = [16 20 24];
porientation = [30 45 60];
norientation = [0 -30 -45 -60 90];
pBank = gabor(wavelength,porientation); % positive (Maximize Resp.)
nBank = gabor(wavelength,norientation); % negative (Minimize Resp.)

[pmag, ~] = imgaborfilt(I_intensityTH_smooth,pBank);
[nmag, ~] = imgaborfilt(I_intensityTH_smooth,nBank);

pMag{length(pBank)} = [];       % Gabor Magnitude Responses
pMag_norm{length(pBank)} = [];  % Gabor Magnitude Responses (Normailized)

nMag{length(pBank)} = [];       % Gabor Magnitude Responses
nMag_norm{length(pBank)} = [];  % Gabor Magnitude Responses (Normailized)

pSumMag = I_intensityTH_smooth.*0;     % Output Image
nSumMag = I_intensityTH_smooth.*0;     % Output Image

for i = 1:length(pBank)
    pMag{i} = pmag(:,:,i);
    pMag_norm{i} = pMag{i};    
    pSumMag = pSumMag + pMag_norm{i};    
end

for i = 1:length(nBank)
    nMag{i} = nmag(:,:,i);
    nMag_norm{i} = nMag{i};
    nSumMag = nSumMag + nMag_norm{i};
end

I_pSum = pSumMag.*I_tree;       %tobe Positive Response
I_nSum = nSumMag.*I_tree;       %tobe Negative Response

I_sum = I_pSum - I_nSum;
I_sum(I_sum<0) = 0;             % Saturate Image at [0 to inf]

% Finding Threshold value
nI_sum = I_sum;
nI_sum(nI_sum == 0) = NaN;
avg_Isum = nanmean(nanmean(nI_sum));
median_Isum = nanmedian(nanmedian(nI_sum));
threshVal = max([avg_Isum median_Isum]);% distribution of remaining response 
%threshVal = 0.0000;
I_sum_segmented = imbinarize(I_sum,threshVal);

%--------------------------------------------------------------------------
%get no of connected area
A = imgaussfilt(medfilt2(I_labA,[5 5]));
B = imgaussfilt(medfilt2(I_labB,[5 5]));
Aseg = imbinarize(A,0);
Bseg = imbinarize(B,0);

%I_magLEdge = edge(I_intensityTH_smooth).*I_tree;
I_magAEdge = edge(A,'Sobel','nothinning').*I_tree.*Aseg;
I_magBEdge = edge(B,'Sobel','nothinning').*I_tree.*Bseg;
I_magLEdge = edge(I_labL,'Sobel','nothinning').*I_tree;

I_magEdge = sign(I_magAEdge.*I_magBEdge.*I_magLEdge); % edge of color 

[I_label, no_region] = bwlabeln(I_sum_segmented);

mode_I_ic(no_region+1) = zeros; % mode value storage (+1 incld BG)
I_label_bin{no_region} = zeros; % Each Region
avgMag(no_region) = zeros;      % each patch avg.magnitude at edges 

I_ic_vector = reshape(I_label,1,[]);
vector_copy = I_ic_vector;
% 1st mode (Always background)
for i = 1:(no_region+1)
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end

for i = 2:(no_region+1)
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0; % pixels not equal to mode set = 0
    I_label_bin{i-1} = sign(temp);  % single patch, not collected patch
end
% Multiply all and calculate average magnitude on edges
for i = 1:length(I_label_bin)
    I_label_tmp = I_label_bin{i};    
    I_sum_seg_edge = I_magEdge.*I_label_tmp.*I_sum;
    I_sum_seg_edge(I_sum_seg_edge==0) = NaN;
    avgMag(i) = nanmean(nanmean(I_sum_seg_edge));
end

% select maximum avg.magnitude
[~,iidx] = max(avgMag);
%I_result = I_label_bin{iidx};



I_result = (50*I_label_bin{iidx})+I_labL+(100*I_magEdge);
%figure(); imshow(I_show,[]); hold; 
end

%{
%test skeletonized
BW3 = bwmorph(I_sum_segmented,'skel',Inf);
figure
imshow(BW3)
%}

%{
% Remove small area in image by keeping 10-largest area
NO_REGION = 10;
mode_I_ic(NO_REGION+1) = zeros;     % mode value storage (+1 incld BG)
[I_label, ~] = bwlabeln(I_sum_segmented);
I_ic_vector = reshape(I_label,1,[]);
vector_copy = I_ic_vector;

for i = 1:(NO_REGION+1)             % 1st area mode (Always background)
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end


I_label_bin{NO_REGION} = zeros;     % Collect Selected mode-area
I_ranked = I_sum_segmented.*0;      % NOREGION Areas -ranked image 
avg_patchmag(NO_REGION) = 0;

for i = 2:(NO_REGION+1)
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0; % pixels not equal to mode set = 0
    I_label_bin{i-1} = logical(temp);        % each single patch
    
end

for i = 1:length(I_label_bin)
   I_ranked = I_ranked + I_label_bin{i};
   tempNAN = double(I_label_bin{i}.*I_pSum);
   tempNAN(tempNAN ==0) = NaN;
   avg_patchmag(i) = nanmean(nanmean(tempNAN));
   clear tempNAN;
end


%I_ranked = imbinarize(I_ranked);
%choose only max one patch
[~,midx] = max(avg_patchmag);

I_result = I_label_bin{midx};

I_show  = (0.4.*I_hsv3)+(0.5.*I_result);
%imshow(I_show); truesize;
%}

%end

