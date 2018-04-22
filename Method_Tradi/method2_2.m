% ------------------------------------------------------------------------
% Method2 : Static Color & Gabor Positive Bank on Low Edges Max Vote
% ------------------------------------------------------------------------

function [I_le_segmented_mode, t0] = method2_2(IMG_NO,IMG_DIR)    

tic;                % timer start

NO_REGION = 12;
%IMG_NO = 53;
%IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),'.jpg');

I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

% Tree thresholding
th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level);

% Single ROI :: remove smaller region (keep only tree region) 
noOfOne = ceil(sum(sum(I_hsv3_thresh))/3);
I_tree = bwareaopen(I_hsv3_thresh,noOfOne);
clear noOfOne


I_hsv3_thresh_d = double(I_tree);
I_hsv3_thresh_d(I_hsv3_thresh_d == 0) = -1; % outside ROI =  -1;


I_mask1 = I_hsv3_thresh_d.*I_hsv1;          %Hue image && Tree Area           
I_mask1(I_mask1 <= 0) = -1;

% Warp back X(X>0.5) = 1-X ; reduce k means' group to 5
for i = 1:size(I_mask1,1)
    for j = 1:size(I_mask1,2)
        if I_mask1(i,j) > 0.5
            I_mask1(i,j) = 1-I_mask1(i,j);
        end
    end
end

% Static Hue value threshold at 0.125 (pure red = 0)
I_c1 = imbinarize(I_mask1,0); % Warpped
I_c2 = imbinarize(I_mask1,0.125);
I_c3 = I_c1 .*((1-I_c2).*I_tree);

I_colorSegmented = I_c3;
%------------------------------------------------------------------------
% 2. Intensity & Color Segmented
                                    % remove tiny dot by 3x3 median filter
                                                                  
I_k_filt = medfilt2(I_colorSegmented, [3 3]);
I_hsv3_colorSegmented = I_k_filt.*I_hsv3 ;

%Connected Component Labelling (Rank-Area)
%-----------------------------------------------------------
%   Pick n biggest area(mode) then create sq.bounding box

mode_I_ic(NO_REGION+1) = zeros;     % mode value storage (+1 incld BG)
I_label_bin{NO_REGION} = zeros;     % Each patch (sub-ROI)
[I_label, ~] = bwlabeln(I_hsv3_colorSegmented);
I_ic_vector = reshape(I_label,1,[]);
vector_copy = I_ic_vector;

for i = 1:(NO_REGION+1)
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end

for i = 2:(NO_REGION+1)             % 1st mode (Always background)
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0; % pixels not equal to mode set = 0
    I_label_bin{i-1} = temp;        % single patch, not collected patch
end

I_ranked = I_hsv3.*0;               % Area-ranked image 
for i = 1:length(I_label_bin)
   I_ranked = I_ranked + I_label_bin{i}; 
end

% ------------------------------------------------------------------------
% Gabor
I_hsv3_smooth = imgaussfilt(I_hsv3,0.25);   % Pre-process intensity image
wavelength = [16 20 24];        
orientation = [30 45 60];       % Positive Bank
gBank = gabor(wavelength,orientation);
[mag, ~] = imgaborfilt(I_hsv3_smooth,gBank);

gMag{length(gBank)} = [];       % Gabor Magnitude Responses
gMag_norm{length(gBank)} = [];  % Gabor Magnitude Responses (Normailized)
gMin(length(gBank)) = zeros;    % Minimum Response of Each Bank
gMax(length(gBank)) = zeros;    % Maximum Response of Each Bank
%sumMag = I_hsv3_smooth.*0;      % Output Image
for i = 1:length(gBank)
    gMag{i} = mag(:,:,i);
    %gMin(i) = min(min(gMag{i}));
    %gMax(i) = max(max(gMag{i}));
    %gMag_norm{i} = (gMag{i}-gMin(i))/gMax(i);
    gMag_norm{i} = gMag{i};
    %subplot(2,3,i); imagesc(gMag_norm{i}.*I_k_filt);
    %sumMag = sumMag + imbinarize(gMag_norm{i},0.5);
    %sumMag = sumMag + gMag_norm{i};
end
%{
%--------------------------------------------------------------------------
% Static sum of magnitude thresholding
%--------------------------------------------------------------------------

sumMag = imbinarize(sumMag,3);
%figure();
%imshow((sumMag.*I_k_filt)+0.33.*I_hsv3_smooth );
I_ksegment = (sumMag.*I_ranked)+0.33.*I_hsv3_smooth;


minmag = min(mag(:));

if (min(mag(:)) == 0)
    minmag = 1;
end

I_k_filt_remin = I_k_filt.*minmag;
mag_mask = mag.*I_k_filt_remin; % Gabor Mag * Kmeans_segemtned

normA = (mag_mask - min(mag_mask(:)));
mag_norm = normA ./ max(normA(:));

imagesc(mag_norm); truesize;



%--------------------------------------------------------------------------
% Maximum of avg sum by Rattachai.W (Area)
%--------------------------------------------------------------------------
I_patch{length(I_label_bin)} = [];
for k = 1 : length(I_label_bin)
    I_label_bin_each = imbinarize(I_label_bin{k});  
    I_patch{k} = I_label_bin_each;    
end

% Each Magnitude Response (Normailzed) masked with each Patches
I_patch_mag{NO_REGION,length(gBank)} = [];
value_matrix(NO_REGION,length(gBank)) = zeros;
noOfOne = 1;
for i = 1:length(I_label_bin)
    for j =  1:length(gBank)
        I_patch_mag{i,j} = gMag_norm{j}.*I_patch{i};
        noOfOne = sum(sum(I_patch{i}));
        value_matrix(i,j) = sum(sum(I_patch_mag{i,j}))/noOfOne;
    end
end
clear noOfOne
% Maximum of Averaged Magnitude of Each Patch Area
value_patch = sum(value_matrix,2);
[~, maxidx] = max(value_patch);
I_segmented = I_label_bin{maxidx}+0.33.*I_hsv3_smooth;

%--------------------------------------------------------------------------
% Maximum of avg sum by Rattachai.W (Low_edges) : Max Sum
%--------------------------------------------------------------------------
I_patch{length(I_label_bin)} = [];
I_le{length(I_label_bin)} = [];
for k = 1 : length(I_label_bin)
    I_label_bin_each = imbinarize(I_label_bin{k});  
    I_patch{k} = I_label_bin_each;    
end

% Region Boundary
for i = 1:length(I_label_bin)
    [I_le{i}, ~] = le_image3(I_patch{i});
end

I_le_mag{NO_REGION,length(gBank)} = [];
value_mat_le(NO_REGION,length(gBank)) = zeros;
noOfOne = 1;
for i = 1:length(I_label_bin)
    for j =  1:length(gBank)
        I_le_mag{i,j} = gMag_norm{j}.*I_le{i};
        noOfOne = sum(sum(I_le{i}));
        value_mat_le(i,j) = ((sum(sum(I_le_mag{i,j})))/noOfOne);
    end
end
clear noOfOne
value_le = sum(value_mat_le,2);
[~, maxidx] = max(value_le);
I_le_segmented = I_le{maxidx}+ (0.3.*I_hsv3_smooth);

%}

%--------------------------------------------------------------------------
% Vote(Mode)the maximum of avg low_edges magnitude 
%--------------------------------------------------------------------------
I_patch{length(I_label_bin)} = [];
I_le{length(I_label_bin)} = [];
for k = 1 : length(I_label_bin)
    I_label_bin_each = imbinarize(I_label_bin{k});  
    I_patch{k} = I_label_bin_each;    
end

% Region Boundary
for i = 1:length(I_label_bin)
    [I_le{i}, ~] = le_image(I_patch{i});
end

I_le_mag{NO_REGION,length(gBank)} = [];
value_mat_le(NO_REGION,length(gBank)) = zeros; % response of each bank
noOfOne = 1;                                   % initial divier set to 1
for i = 1:length(I_label_bin)
    for j =  1:length(gBank)
        I_le_mag{i,j} = gMag_norm{j}.*I_le{i};
        noOfOne = sum(sum(I_le{i}));
        dataExtracted = (  sum(sum(I_le_mag{i,j})) )  /noOfOne;
        value_mat_le(i,j) = dataExtracted;
    end
end
clear noOfOne

[~, maxresponse] = max(value_mat_le,[],1);
I_le_segmented_mode = (I_le{mode(maxresponse)})+ (0.3.*I_hsv3_smooth);
t0 = toc;

end




