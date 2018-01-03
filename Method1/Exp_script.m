%measurement script

IMGPATH = 'Image_acq/RES/C910_M1/T1_L1.jpg';
TH_SOBEL = 0.04;
TH_CANNY = 0.38;
HOUGH_VOTE = 6;
HOUGH_THETA = 15;
RIM_WIDTH = 5;
%SELECT_CLUS = im_clus6;

% Pixel Brightness Calcucation
tree_brgn = tree_mask.*I_hsv3;
tree_brgn = sum(tree_brgn(tree_brgn >=0));
tree_brgn_SOURCE = tree_brgn/innr_area;
clear tree_brgn

rimL_brgn = rimL_mask.*I_hsv3;
rimL_brgn = sum(rimL_brgn(rimL_brgn >=0));
rimL_brgn_SOURCE = rimL_brgn/rimL_area;
clear rimL_brgn

rimR_brgn = rimR_mask.*I_hsv3;
rimR_brgn = sum(rimR_brgn(rimR_brgn >=0));
rimR_brgn_SOURCE = rimR_brgn/rimR_area;
clear rimR_brgn

disp(tree_brgn_SOURCE);
disp(rimL_brgn_SOURCE);
disp(rimR_brgn_SOURCE);



sel_clus = imbinarize(im_clus3);
sel_clus_filt = medfilt2(sel_clus,[3 3]);
imshow(sel_clus_filt)
[sel_clus_filt_label, nfound] = bwlabeln(sel_clus_filt);

sel_clus_vector = reshape(sel_clus_filt_label,1,[]);
mo1 = mode(sel_clus_vector);
sel_clus_vector_copy = sel_clus_vector ; 
sel_clus_vector_copy(sel_clus_vector == mo1) = []; 
mo2 = mode(sel_clus_vector_copy);



sel_clus_filt_label(sel_clus_filt_label ~= mo2) = 0;
imshow(sel_clus_filt_label);



tap_edge = edge(sel_clus_filt_label,'Canny',0.99);
imshow(tap_edge);
