% 5
im_clus = im_clus2;
im_clus = imbinarize(im_clus);
figure('Name','Selected cluster');
imshow(im_clus);

% overlapped edges detected & Segmented Cluster
% sobel edges
I_sobel_in = im_clus & I_sobel & sign(tree_mask2); % edge in color region
I_sobel_out = (I_sobel - I_sobel_in) & sign(tree_mask2);
figure('Name','Intersected Sobel edges & Selected Cluster Region');
subplot(1,2,1);
imshow(I_sobel_in);     title('inside cluster region');
subplot(1,2,2);
imshow(I_sobel_out);    title('outside');

% canny edges
I_canny_in = im_clus & I_canny & sign(tree_mask2); % edge in color region
I_canny_out = (I_canny - I_canny_in) & sign(tree_mask2);
figure('Name','Intersected Canny edges & Selected Cluster Region');
subplot(1,2,1);
imshow(I_canny_in); title('inside cluster region');
subplot(1,2,2);
imshow(I_canny_out); title('outside');



% overlapped edges detected & Segmented Cluster
% with morphological operations

% Squre structural element wide = 10
SE_open = strel('disk',3,0);
SE_close = strel('line',30,-45);
% remove small patch :: openning operation
im_clus_morph_open = imopen(im_clus,SE_open);
% remove holes       :: closing
im_clus_morph_close = imclose(im_clus_morph_open,SE_close);

figure('Name','Morphological Operations');
subplot(1,2,1);
imshow(im_clus_morph_open);     title('1st Open');
subplot(1,2,2);
imshow(im_clus_morph_close);    title('Close');

% Region Labelling 
% Apply median filter to Selected Cluster (3sq.mask,7sq.mask)
im_clus_filt = medfilt2(im_clus,[7 7]);
[im_clus_label,nReg] = bwlabel(im_clus_filt);

figure('Name','Median filter');
subplot(1,2,1);
imshow(im_clus);     title('Selected Cluster');
subplot(1,2,2);
imshow(im_clus_filt);    title('Median filter applied');







