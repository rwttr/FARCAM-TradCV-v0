% 3
% Bounding Box Clustered Image Patch

%each patch(Bounded) image in labelled image
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
