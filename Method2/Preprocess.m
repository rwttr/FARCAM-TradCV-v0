% 1
%Method2 1st file 
%Threshold intensity channel

IMG_NO = 1;
END_TY = '.jpg';
IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_resize1\';

IMGPATH = strcat(IMG_DIR,int2str(IMG_NO),END_TY);

%I_rgb = imread('Image_acq/RES/C910_M1/T1_L2.jpg'); %Source IMG
I_rgb = imread(IMGPATH);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level);
I_hsv3_thresh_d = double(I_hsv3_thresh);
I_hsv3_thresh_d(I_hsv3_thresh_d == 0) = -1;
%figure();imshowpair(I_hsv3,I_hsv3_thresh,'montage');

mask1 = I_hsv3_thresh_d;
%mask1_inv = abs(I_hsv3_thresh-1);
I_mask1 = mask1.*I_hsv1;                        %Hue image && Foreground
I_mask1(I_mask1 <= 0) = -1;
%I_mask1 = medfilt2(I_mask1);
%I_mask1 = imgaussfilt(I_mask1);

%warp back X(X>0.5) = 1-X
%I_mask1(I_mask1 >0.5) = 1-I_mask1;
for i = 1:size(I_mask1,1)
    for j = 1:size(I_mask1,2)
        if I_mask1(i,j) > 0.5
            I_mask1(i,j) = 1-I_mask1(i,j);
        end
    end
end

figure();imshowpair(I_hsv3,I_mask1,'montage');

%K-means Color
nClus = 6; % number of cluster
ini_centroid = [-1 0 0.2 0.3 0.4 0.5]'; %initial seed for kmeans
[nRows, nCols] = size(I_mask1);


I_kresult(nRows, nCols, nClus) = zeros;                 % Kmeans Clustered
I_k_binary(nRows, nCols, nClus) = zeros('logical');     % -
I_mask1_fmtd = reshape(I_mask1,nRows*nCols,1);
[clus_idx,cen_Color] = kmeans(I_mask1_fmtd, nClus,'Start',ini_centroid);
disp(cen_Color);
%disp(sort(cen_Color));
pixel_labels = reshape(clus_idx,nRows,nCols);   %result image
figure('Name','Kmeans Group');
imshow(pixel_labels,[]), title('image labeled by cluster index');

for k = 1:nClus
    I_temp = I_kresult(:,:,k) + pixel_labels;
    I_temp(I_temp ~= k) = 0;
    I_kresult(:,:,k) = sign(I_temp);
    %I_k_binary(:,:,k) = imbinarize(I_kresult(:,:,k));
end

figure('Name','Output Cluster Image');
for k = 1:nClus
    subplot(1,nClus,k);
    imshow(I_k_binary(:,:,k));
    title(['Cluster',num2str(k)]); 
    xlabel(cen_Color(k));
end






