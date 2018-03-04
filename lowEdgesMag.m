function [ low_edges_mag,low_edges ] = lowEdgesMag( I_mag,I_bw )

% lookup mag image at low_edges from I_bw
IMGRZ_WIDTH = size(I_bw,2);
%------------------------------------------------------------------------
% Section2 : low_edges Extraction
%------------------------------------------------------------------------
inputIMG_shpA = I_bw;

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


%-------------------------------------------------------------------------
% Section3 : Compute feature vector
%------------------------------------------------------------------------
low_edges_mag(length(low_edges)) = zeros;

for j = 1:length(low_edges) % loop in low_edges
    low_edges_mag(1,j) = I_mag(size(I_bw,1)-low_edges(j),j);
end


end









