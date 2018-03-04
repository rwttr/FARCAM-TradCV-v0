function [ raw2, low_edges ] = extShape2( I_toext_bw, nbin, ma_size )

MOV_SMOOTH = ma_size;    % smoothing window size
IMGRZ_WIDTH = 120;
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

figure('Name','Resized Boundary Image');
imshow(bdry_I);


figure('Name','Lowest Boundary Normalized');
plot(low_edges_norm);
axis([1 120 0 1]);
xlabel('patch width resized (pixels)') % x-axis label
ylabel('Normalized distance') % y-axis label


figure();
plot(low_edges_norm_smooth);
axis([1 120 0 1]);
xlabel('patch width resized (pixels)') % x-axis label
ylabel('Normalized distance') % y-axis label
%}
bincell_distance{nbin} = zeros;
bincell{nbin} = zeros;
feacell(nbin*3) = zeros;
binWidth = floor(IMGRZ_WIDTH/nbin);

for j = 1:nbin
    bincell{j} = dev_sig((binWidth*(j-1)+1):(binWidth*j));
    bincell_distance{j} = low_edges_norm_smooth((binWidth*(j-1)+1):(binWidth*j));
    
    feacell(1+(3*(j-1))) = 100*sum(bincell{j}(bincell{j}<0));
    feacell(2+(3*(j-1))) = mean(bincell_distance{j});
    feacell(3+(3*(j-1))) = 100*sum(bincell{j}(bincell{j}>0));    
end
raw_point = low_edges_norm_smooth;
shapeFeature = feacell;
raw2 = low_edges_norm_smooth(binWidth:end-binWidth);
end

