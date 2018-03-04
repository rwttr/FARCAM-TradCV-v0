function [ feaVec ] = extShp5Gabor( I_xt_hsv3,I_xt_bw )

% V5 + Gabor filter bank - zero padding

% I_xt_bw = patch_bw_POS{1};
% I_xt_hsv3 = patch_hsv3_POS{1};

TARGET_LEN = 500; % length of source image (1MP)
IMGRZ_WIDTH = size(I_xt_bw,2);

WAVELENGTH = [8 12 16 24 30];
ORIENTATION = [0 30 45 60 90];

gBank = gabor(WAVELENGTH,ORIENTATION);

%-----------------------------------------------------------------------
% Section1 : Gabor Filter compute on I_HSV3
%-----------------------------------------------------------------------
inputIMG_gabB = I_xt_hsv3;

outMag = imgaborfilt(inputIMG_gabB,gBank);


%------------------------------------------------------------------------
% Section2 : low_edges Extraction
%------------------------------------------------------------------------
inputIMG_shpA = I_xt_bw;

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
low_edges_padd = [zeros(1,TARGET_LEN-(length(low_edges))) low_edges];


%-------------------------------------------------------------------------
% Section3 : Compute feature vector
%------------------------------------------------------------------------
low_edges_mag(length(gBank),length(low_edges)) = zeros;
low_edges_gMag_looper(1,length(low_edges)) = zeros;

% low_edges contains row index 
for i = 1:length(gBank) % loop in each gabor response
    
    for j = 1:length(low_edges) % loop in low_edges
        low_edges_gMag_looper(1,j) = outMag(size(I_xt_bw,1)-low_edges(j),j,i);
    end
    low_edges_mag(i,:) = low_edges_gMag_looper;
end

% pre-paded to TARGET length
low_edges_mag_padd = [zeros(length(gBank),...
    (TARGET_LEN-(length(low_edges)))) low_edges_mag];

feaVec = mean(low_edges_mag_padd,2)';

end








