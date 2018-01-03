% kmeans : nClus = Number of cluster 
nClus = 4; % number of cluster

nRows = size(tree_area,1);
nCols = size(tree_area,2);
tree_area_formatted = reshape(tree_area,nRows*nCols,1);
[clus_idx,cen_Color] = kmeans(tree_area_formatted, nClus);
%disp(cen_Color);
disp(sort(cen_Color));
%image after kmeans clustering
pixel_labels = reshape(clus_idx,nRows,nCols);
%figure('Name','Kmeans Group');
%imshow(pixel_labels,[]), title('image labeled by cluster index');

%each cluster
pixel_labels = uint8(pixel_labels);
im_clus1 = pixel_labels;
im_clus2 = pixel_labels;
im_clus3 = pixel_labels;
im_clus4 = pixel_labels;

%create cluster mask : filter out clus number then convert to binary mask
im_clus1(im_clus1 ~= 1) = 0; im_clus1 = sign(im_clus1);
im_clus2(im_clus2 ~= 2) = 0; im_clus2 = sign(im_clus2);
im_clus3(im_clus3 ~= 3) = 0; im_clus3 = sign(im_clus3);
im_clus4(im_clus4 ~= 4) = 0; im_clus4 = sign(im_clus4);

% ////////////////////////////////////////////////////////////////////////
% Displaying section
%/////////////////////////////////////////////////////////////////////////

figure('Name','Segnmented Image no.of Cluster = 4');

subplot(1,4,1);
imshow(repmat(im_clus1,[1,1,3]).*I_rgb); 
title('Cluster1');
xlabel(cen_Color(1));

subplot(1,4,2);
imshow(repmat(im_clus2,[1,1,3]).*I_rgb); 
title('Cluster2');
xlabel(cen_Color(2));

subplot(1,4,3);
imshow(repmat(im_clus3,[1,1,3]).*I_rgb); 
title('Cluster3'); 
xlabel(cen_Color(3));

subplot(1,4,4);
imshow(repmat(im_clus4,[1,1,3]).*I_rgb); 
title('Cluster4');
xlabel(cen_Color(4));
%}
