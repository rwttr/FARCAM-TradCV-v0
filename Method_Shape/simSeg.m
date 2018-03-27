function [I_rgb,I_tree,I_outE,I_outE2,I_result] = simSeg( IMG_NO, IMG_DIR )

%IMG_NO = 89;
%IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),'.jpg');

I_rgb = imread(IMGPATH);

% test for lab color model
I_lab = rgb2lab(I_rgb,'WhitePoint','e');
I_labL = I_lab(:,:,1);
I_labA = I_lab(:,:,2);
I_labB = I_lab(:,:,3);

th_level = 22;                  % staic threshold
% segemnt for tree
I_intensity_thresh = imbinarize(I_labL,th_level);
noOfOne = ceil(sum(sum(I_intensity_thresh))/3);  % remove disconnected area
I_tree = bwareaopen(I_intensity_thresh,noOfOne); % tree area

% preprocess/smooth for noise reduction
L = imgaussfilt(I_labL,0.25);
A = imgaussfilt(medfilt2(I_labA,[3 3]),0.1);
B = imgaussfilt(medfilt2(I_labB,[3 3]),0.1);
Aseg = imbinarize(A,0); % threshold for red area
Bseg = imbinarize(B,3); % threshold for yellow area

%I_magLEdge = edge(I_intensityTH_smooth).*I_tree;
I_aEdge = edge(A,'Sobel','nothinning').*I_tree.*Aseg; % mask out
I_bEdge = edge(B,'Sobel','nothinning').*I_tree.*Bseg;
I_lEdge = edge(L,'Sobel','nothinning').*I_tree;
I_asmt = I_aEdge; %imbinarize(imgaussfilt(I_aEdge,0.5),0);
I_bsmt = I_bEdge; %imbinarize(imgaussfilt(I_bEdge,0.5),0);


I_comEdge = ((I_asmt+I_bsmt).*I_lEdge); % common edges
I_comEdge = imbinarize(I_comEdge,0);

%--------------------------------------------------------------------------
% Create Magnitude Image for detect desired edges' orientation/direction
%--------------------------------------------------------------------------
I_intensityTH_smooth = imgaussfilt(I_labL,0.20);

% Gabor for Segmentation
wavelength = [16 20 24];
porientation = [30 45 60];              % tobe accept orientation
norientation = [0 -30 -45 -60 90];      % tobe reject orientation
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

I_magSum = I_pSum - I_nSum;     %heat map image

% -------------------------------------------------------------------------
% Pick a single desired edge by maxmimum heat
% -------------------------------------------------------------------------
% option: enable map threshold for speed enhancement
I_map = imbinarize(I_magSum,0);
[I_label, no_region] = bwlabeln(I_comEdge.*I_map);

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
    I_sum_edge = I_comEdge.*I_label_tmp.*I_magSum;
    
    avgMag(i) = sum(sum(I_sum_edge));
end
I_outE = I_comEdge.*I_map;
I_outE2 = I_map .* I_magSum;
% select maximum avg.magnitude
[~,iidx] = max(avgMag);
I_result = (250*I_label_bin{iidx})+I_labL;
%figure(); imshow(I_result,[]);

end


