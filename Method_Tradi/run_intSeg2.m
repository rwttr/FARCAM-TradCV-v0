
%IMG_NO = 44;
IMG_DIR = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';

SAVE_DIR = 'C:\Users\Rattachai\Desktop\ShpAna2\seg1_gaborMap_LabEdges_v2';




for img_no = 1:102
[I_rgb,I_tree,I_colorEdge,I_map,I_ksegment] = simSeg(img_no,IMG_DIR);    
fig1 = figure();
subplot(1,5,1); imshow(I_rgb); title('Source RGB');
subplot(1,5,2); imshow(I_tree,[]); title('Tree segmented');
subplot(1,5,3); imagesc(I_map); title('Gabor Response');
subplot(1,5,4); imshow(I_colorEdge,[]); title('Color Edges');
subplot(1,5,5); imshow(I_ksegment,[]);  title('Detected Tapped Area'); truesize; 

fname = int2str(img_no);
saveas(fig1, fullfile(SAVE_DIR, fname), 'png');
close all
end