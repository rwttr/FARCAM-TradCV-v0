% add erosion   
function [I_le_segmented] = kmeansSeg2(IMG_NO,IMG_DIR)    
% 1
%Threshold intensity channel
NO_REGION = 10;
%IMG_NO = 44;
%IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),'.jpg');

I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level);
I_hsv3_thresh_d = double(I_hsv3_thresh);
I_hsv3_thresh_d(I_hsv3_thresh_d == 0) = -1;

%figure('Name','Input Intensity Image - Thresholded Image');
%imshowpair(I_hsv3,I_hsv3_thresh,'montage');

I_mask1 = I_hsv3_thresh_d.*I_hsv1;  %Hue image && Foreground            
I_mask1(I_mask1 <= 0) = -1;

%warp back X(X>0.5) = 1-X
%I_mask1(I_mask1 >0.5) = 1-I_mask1;
for i = 1:size(I_mask1,1)
    for j = 1:size(I_mask1,2)
        if I_mask1(i,j) > 0.5
            I_mask1(i,j) = 1-I_mask1(i,j);
        end
    end
end

%K-means Color
NO_CLUS = 6; % number of color cluster
INI_CTND = [-1 0 0.2 0.3 0.4 0.5]'; %initial seed for kmeans
[nRows, nCols] = size(I_mask1);

I_kresult(nRows, nCols, NO_CLUS) = zeros;           % each kmeans Clustered

I_mask1_fmtd = reshape(I_mask1,nRows*nCols,1);
[clus_idx,~] = kmeans(I_mask1_fmtd, NO_CLUS,'Start',INI_CTND);

pixel_labels = reshape(clus_idx,nRows,nCols);   %result image

for k = 1:NO_CLUS
    I_temp = I_kresult(:,:,k) + pixel_labels;
    I_temp(I_temp ~= k) = 0;
    I_kresult(:,:,k) = sign(I_temp);
end


% ////////////////////////////////////////////////////////////////////////

% 2
%Intensity & Color Segmented
%Suppress Small dot by median filter
SELECT_CLUSTER = 2;

%Apply median filter : I_k_filt
I_k_filt = medfilt2(I_kresult(:,:,SELECT_CLUSTER), [1 1]);
I_ic = I_k_filt.*I_hsv3 ;

%imshowpair(I_kresult(:,:,SELECT_CLUSTER),I_k_filt,'montage');
%imshow(I_ic);

%   Connected Component Labelling (Rank-Area)
%   --------------------------------
%   Pick n biggest area(mode) then create sq.bounding box
%   NO_REGION = NO_REGION+1;       % No. of Biggest area +1 include BG
mode_I_ic(NO_REGION+1) = zeros; % mode value storage (+1 incld BG)
[I_label, ~] = bwlabeln(I_ic);
I_ic_vector = reshape(I_label,1,[]);
vector_copy = I_ic_vector;
% 1st mode (Always background)
for i = 1:(NO_REGION+1)
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end

% Collect Selected mode
I_label_bin{NO_REGION} = zeros;

for i = 2:(NO_REGION+1)
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0; % pixels not equal to mode set = 0
    I_label_bin{i-1} = temp;        % single patch, not collected patch
end

% Area-ranked image 
I_ranked = I_ic.*0;
for i = 1:length(I_label_bin)
   I_ranked = I_ranked + I_label_bin{i}; 
end

% Gabor
I_hsv3_smooth = imgaussfilt(I_hsv3,0.25);
wavelength = [12 20];
orientation = [30 45 60];
gBank = gabor(wavelength,orientation);
[mag, ~] = imgaborfilt(I_hsv3_smooth,gBank);

gMag{length(gBank)} = [];       % Gabor Magnitude Responses
gMag_norm{length(gBank)} = [];  % Gabor Magnitude Responses (Normailized)
gMin(length(gBank)) = zeros;    % Minimum Response of Each Bank
gMax(length(gBank)) = zeros;    % Maximum Response of Each Bank
sumMag = I_hsv3_smooth.*0;      % Output Image
for i = 1:length(gBank)
    gMag{i} = mag(:,:,i);
    gMin(i) = min(min(gMag{i}));
    gMax(i) = max(max(gMag{i}));
    gMag_norm{i} = (gMag{i}-gMin(i))/gMax(i);
    %subplot(2,3,i); imagesc(gMag_norm{i}.*I_k_filt);
    %sumMag = sumMag + imbinarize(gMag_norm{i},0.5);
    sumMag = sumMag + gMag_norm{i};
end

%--------------------------------------------------------------------------
% Static sum of magnitude thresholding
%--------------------------------------------------------------------------

sumMag = imbinarize(sumMag,3);
%figure();
%imshow((sumMag.*I_k_filt)+0.33.*I_hsv3_smooth );
I_ksegment = (sumMag.*I_ranked)+0.33.*I_hsv3_smooth;

%{
minmag = min(mag(:));

if (min(mag(:)) == 0)
    minmag = 1;
end

I_k_filt_remin = I_k_filt.*minmag;
mag_mask = mag.*I_k_filt_remin; % Gabor Mag * Kmeans_segemtned

normA = (mag_mask - min(mag_mask(:)));
mag_norm = normA ./ max(normA(:));

imagesc(mag_norm); truesize;

%}

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
% Maximum of avg sum by Rattachai.W (Low_edges)
%--------------------------------------------------------------------------
I_patch{length(I_label_bin)} = [];
I_le{length(I_label_bin)} = [];
for k = 1 : length(I_label_bin)
    I_label_bin_each = imbinarize(I_label_bin{k});  
    I_patch{k} = I_label_bin_each;    
end

% Region Boundary
for i = 1:length(I_label_bin)
    [I_le{i}, ~] = le_image2(I_patch{i});
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


end


%{

I_clused_bw{length(I_label_bin),2} = []; %image patch storing cell
I_clused_hsv3{length(I_label_bin),1} = [];
I_patch{length(I_label_bin)} = [];
% BB each area
for k = 1 : length(I_label_bin)

    I_label_bin_each = imbinarize(I_label_bin{k});
    stats_box = regionprops(I_label_bin_each,'BoundingBox');

    BB = stats_box.BoundingBox;  
    I_toext = I_hsv3( ceil(BB(2)):(floor(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(floor(BB(1))+ceil(BB(3))));
    I_toext_bw = I_label_bin_each( ceil(BB(2)):(floor(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(floor(BB(1))+ceil(BB(3))));
  
    I_clused_hsv3{k,1} = I_toext;                  
    I_clused_bw{k,1} = I_toext_bw;
    I_clused_bw{k,2} = I_label_bin_each;
    clear stats_box I_toext I_toext_bw;
end

%}



