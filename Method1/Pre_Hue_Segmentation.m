% 3

tree_mask = I_hsv1 & 0;         % Declared 2D image as a mask
tree_mask = tree_mask -1;       % all element = -1 (mask with -1)
rimL_mask = tree_mask;
rimR_mask = tree_mask;

RIM_WIDTH = 5;                  % percent
rim_width = ceil(tree_width/RIM_WIDTH);

innr_area = 0;
rimL_area = 0;
rimR_area = 0;

%inner tree area pixel = 1
%outter area = -1
for j =1:length(tree_width)
    for k = line_left(j,1):line_left(j,1)+tree_width(j,1)
        tree_mask(j,k) = 1;
        innr_area = innr_area +1;
    end
end

%rim L 
for j =1:length(tree_width)
    for k = line_left(j,1):(line_left(j,1)+rim_width(j,1))
        rimL_mask(j,k) = 1;
        rimL_area = rimL_area +1;
    end
end

%rim R
for j =1:length(tree_width)
    for k = (line_right(j,1)-rim_width(j,1)):line_right(j,1)
        rimR_mask(j,k) = 1;
        rimR_area = rimR_area +1;
    end
end

tree_mask2 = tree_mask;         % mask with 0
tree_mask2(tree_mask2 == -1) = 0;
tree_mask2 = uint8(tree_mask2);

% Element-wise multiplication   C = A.*B
% tree_area  = hue data inside tree mask 
tree_area = I_hsv1.*tree_mask;             % Clean Source
%tree_area = medfilt2(I_hsv1).*tree_mask;  % Filtered Source
tree_area(tree_area<=0) = -1;

%hist(tree_area);
%h = histogram(tree_area,'BinEdges',1/255:1/256:1);

figure('Name','Source RGB image');
subplot(1,2,1); 
imshow(I_rgb); title('Source');
subplot(1,2,2); 
imshow(tree_mask2.*uint8(I_hsv1*255));
%imshow(repmat(tree_mask2,[1,1,3]).*I_rgb); 
title('Source');title('Source with Detected tree as ROI');


