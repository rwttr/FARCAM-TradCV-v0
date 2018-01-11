
IMG_dir = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_resize1\';
END_TY = '.jpg';
image_k = 50; %image_no
centroid_mat(50,6) = zeros;

for loop_counter = 1:image_k

imgpath = strcat(IMG_dir,int2str(loop_counter),END_TY);
I_rgb = imread(imgpath);
I_hsv = rgb2hsv(I_rgb);
I_hsv1 = I_hsv(:,:,1); % Hue
I_hsv3 = I_hsv(:,:,3); % Value

th_level = graythresh(I_hsv3);
I_hsv3_thresh = imbinarize(I_hsv3,th_level);
I_hsv3_thresh_d = double(I_hsv3_thresh);
I_hsv3_thresh_d(I_hsv3_thresh_d == 0) = -1;
%figure();imshowpair(I_hsv3,I_hsv3_thresh,'montage');

mask1 = I_hsv3_thresh_d;
I_mask1 = mask1.*I_hsv1;                        %Hue image && Foreground
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
nClus = 6; % number of cluster
ini_centroid = [-1 0 0.2 0.3 0.4 0.5]'; %initial seed for kmeans
[nRows, nCols] = size(I_mask1);

I_mask1_fmtd = reshape(I_mask1,nRows*nCols,1);
[~,cen_Color] = kmeans(I_mask1_fmtd, nClus,'Start',ini_centroid);
%disp(cen_Color);
disp(loop_counter);
center_color = cen_Color';
centroid_mat(loop_counter,:) = center_color;
clear imgpath

end