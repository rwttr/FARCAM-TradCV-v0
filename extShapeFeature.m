function [shapeFeature] = extShapeFeature( I_toext_bw )
%EXTSHAPEFEATURE Summary of this function goes here
% Read Kmeans Image Patch and Extract shape feature
% Resize width of input bw image to IMGRZ_WIDTH

MOV_SMOOTH = 12;    % smoothing window size
IMGRZ_WIDTH = 120;  % image resize width in pixel +1(odd)

inputIMG =  I_toext_bw;
%{
%inputIMG(inputIMG ==0) = -1; %background = -1
[inputIMG_label, nfound] = bwlabeln(I_toext_bw);

if(nfound > 1) % more than one connected-region detected
    %inputIMG_label_vector = reshape(inputIMG_label,1,[]); 
    pxCount(1:nfound) = zeros;
    for q = 1:nfound
        pxCount(q) = sum(inputIMG_label(inputIMG_label==(q-1)));
    end    
    
    inputIMG = bwareaopen(inputIMG,min(pxCount));
    
end
%}

%//////////////////////////////////////////////////////////////////////////
%inputIMG_shpA = I_toext_bw;
inputIMG_shpA = inputIMG;

inputIMG_shpA = imresize(inputIMG_shpA,[NaN, IMGRZ_WIDTH]);

% Region Boundary
bdry_idx = bwboundaries(inputIMG_shpA,'noholes');
bdry_I = imbinarize(inputIMG_shpA.*0);
idx_x = bdry_idx{1,1}(:,1); %{1,1} means first structure element
idx_y = bdry_idx{1,1}(:,2);

for c = 1:length(idx_x)
    bdry_I(idx_x(c),idx_y(c)) = 1;
end

%(inverse projection)lowest edges(of perimeter) onto image bottom (x-axis)
% last element of low_rowedges always = 1 (no boundary in bdry_I)
rowVal = 0;
[nrows,ncols] = size(bdry_I);
%ncols = ncols-1;

low_edges(1:(IMGRZ_WIDTH-1)) = 0;
for c = 1:ncols
    rowVal = 0;
    for row = 1:nrows    
        if(bdry_I(row,c)==1)
            if(row>=rowVal)
                rowVal = row;
            end
        end        
    end       
    low_edges(c) = nrows-rowVal;
    rowVal = 0;
end

% Normailize Magnitude to be in [0,1] range 
low_edges_norm = low_edges - min(low_edges(:));
low_edges_norm = low_edges_norm ./ max(low_edges_norm(:));

% Smooth by moving average filter
low_edges_norm_smooth = movmean(low_edges_norm,MOV_SMOOTH);

% 1st derivative / sign histogram
dev_low_edges = diff(low_edges_norm_smooth);
dev_sig = dev_low_edges;
dev_sig(IMGRZ_WIDTH) = dev_sig(IMGRZ_WIDTH-1);
%Display Section

%{
figure('Name','input Binary Image');
imshow(inputIMG_shpA);
title('Resized image');

figure('Name','Resized Boundary Image');
imshow(bdry_I);

figure('Name','Lowest Boundary Normalized');
plot(low_edges_norm);
hold on;
plot(low_edges_norm_smooth);
hold on;
plot(dev_low_edges);
%}

bin1 = dev_sig(1:20);
bin2 = dev_sig(21:40);
bin3 = dev_sig(41:60);
bin4 = dev_sig(61:80);
bin5 = dev_sig(81:100);
bin6 = dev_sig(101:119);

fea1 = [sum(bin1(bin1<0)) sum(bin1(bin1==0)) sum(bin1(bin1>0))];
fea2 = [sum(bin2(bin2<0)) sum(bin2(bin2==0)) sum(bin2(bin2>0))];
fea3 = [sum(bin3(bin3<0)) sum(bin3(bin3==0)) sum(bin3(bin3>0))];
fea4 = [sum(bin4(bin4<0)) sum(bin4(bin4==0)) sum(bin4(bin4>0))];
fea5 = [sum(bin5(bin5<0)) sum(bin5(bin5==0)) sum(bin5(bin5>0))];
fea6 = [sum(bin6(bin6<0)) sum(bin6(bin6==0)) sum(bin6(bin6>0))];

shapeFeature = 100*[fea1 fea2 fea3 fea4 fea5 fea6];

end

