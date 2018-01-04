% Read Kmeans Image Patch and Extract shape feature

MOV_SMOOTH = 12;    % smoothing window size
IMGRZ_WIDTH = 121;  % image resize width in pixel +1(odd)
SIZE_BIN = 40;

inputIMG_shpA = I_toext_bw;
inputIMG_shpA = imresize(inputIMG_shpA,[NaN, IMGRZ_WIDTH]);

figure('Name','input Binary Image');
imshow(inputIMG_shpA);
title('Resized image');

% Region Boundary
bdry_idx = bwboundaries(inputIMG_shpA,'noholes');
bdry_I = imbinarize(inputIMG_shpA.*0);
idx_x = bdry_idx{1,1}(:,1); %{1,1} means first structure element
idx_y = bdry_idx{1,1}(:,2);

for c = 1:length(idx_x)
    bdry_I(idx_x(c),idx_y(c)) = 1;
end
figure();
imshow(bdry_I);

%(inverse projection)lowest edges(of perimeter) onto image bottom (x-axis)
% last element of low_rowedges always = 1 (no boundary in bdry_I)
rowVal = 0;
[nrows,ncols] = size(bdry_I);
ncols = ncols-1;
clear low_edges low_edges_norm low_edges_norm_smooth;
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
dev_sig = sign(dev_low_edges);

figure('Name','Lowest Boundary Normalized');
plot(low_edges_norm);
hold on;
plot(low_edges_norm_smooth);
hold on;
plot(dev_low_edges);


l_bin = dev_sig(1:SIZE_BIN);
m_bin = dev_sig(SIZE_BIN:SIZE_BIN*2);
r_bin = dev_sig(SIZE_BIN*2:(SIZE_BIN*3)-1);

feaL = [sum(l_bin<0) sum(l_bin==0) sum(l_bin>0)];
feaM = [sum(m_bin<0) sum(m_bin==0) sum(m_bin>0)];
feaR = [sum(r_bin<0) sum(r_bin==0) sum(r_bin>0)];

shapeFeature = [feaL feaM feaR];
