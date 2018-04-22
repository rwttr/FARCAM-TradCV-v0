function [ outIMG,low_edges ] = le_image( inputIMG_shpA )
%LE_IMAGE Summary of this function goes here
%   Low_edges Extraction

bdry_idx = bwboundaries(inputIMG_shpA,'noholes');
bdry_I = imbinarize(inputIMG_shpA.*0);
idx_x = bdry_idx{1,1}(:,1);
idx_y = bdry_idx{1,1}(:,2);

for c = 1:length(idx_x)
    bdry_I(idx_x(c),idx_y(c)) = 1;
end

%(inverse projection)lowest edges(of perimeter) onto image bottom (x-axis)
% last element of low_rowedges always = 1 (no boundary in bdry_I)
rowVal = 0;
[nrows,ncols] = size(bdry_I);
%ncols = ncols-1;

low_edges(1:ncols) = zeros;
low_edges2(1:ncols) = zeros;
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
    low_edges2(c) = rowVal;
    if (rowVal == 0)
        low_edges(c) = -1;
        low_edges2(c) = -1;
    end
    rowVal = 0;
end

outIMG = inputIMG_shpA.*0;
for i =  1:ncols
    if (low_edges2(i) > 0)
        outIMG(low_edges2(i),i) = 1;        
    end
end



end

