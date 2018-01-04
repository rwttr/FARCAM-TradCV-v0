% 2
%Intensity & Color Segmented
%Suppress Small dot by median filter
selectedCluster = 2;

%Apply median filter : I_k_filt
I_k_filt = medfilt2(I_kresult(:,:,selectedCluster), [3 3]);
I_ic = I_k_filt.*I_hsv3 ;
imshowpair(I_kresult(:,:,selectedCluster),I_k_filt,'montage');
imshow(I_ic);

% Connected Component Labelling
% Pick n biggest area(mode) then create sq.bounding box
nRegion = 4;    % No. of Biggest area 
mode_I_ic(nRegion) = zeros;
I_label_bin = I_ic * 0;
[I_label, nfound] = bwlabeln(I_ic);
I_ic_vector = reshape(I_label,1,[]);

vector_copy = I_ic_vector;
% 1st mode (Always background)
for i = 1:nRegion
    mode_I_ic(i) = mode(vector_copy);                
    vector_copy(vector_copy == mode_I_ic(i)) = []; 
end

% Collect Selected mode
for i = 2:nRegion
    temp = I_label;
    temp(temp ~= mode_I_ic(i)) = 0;
    I_label_bin = I_label_bin + temp;
end
I_label_bin = imbinarize(I_label_bin);
I_label_hsv3 = I_label_bin .* I_hsv3;
imshowpair(I_label_bin,I_label_hsv3,'montage');

% Bounding Box
imshow(I_label_hsv3);
hold on;
axis normal;
axis on;
stats_box = regionprops(I_label_bin,'BoundingBox');
for k = 1 : length(stats_box)
  BB = stats_box(k).BoundingBox;
  rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],...
  'EdgeColor','green','LineWidth',2 )
end

image_clutered_bw{length(stats_box)} = []; %image patch storing cell
image_clutered_in{length(stats_box)} = [];

for k = 1 : length(stats_box)
  BB = stats_box(k).BoundingBox;  
  I_toext = I_hsv3( ceil(BB(2)):(ceil(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(ceil(BB(1))+ceil(BB(3))));
  I_toext_bw = I_label_bin( ceil(BB(2)):(ceil(BB(2))+ceil(BB(4))),...
                        ceil(BB(1)):(ceil(BB(1))+ceil(BB(3))));
  
  image_clutered_in{k} = I_toext;                  
  image_clutered_bw{k} = I_toext_bw;
  
end


