
IMG_dir = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_resize1\';
n_region = 5;

image_k = 50; %image_no

[patch_hsv3,patch_bw,ctVal,~] = kmeansSegment(IMG_dir,image_k,n_region);

figure();
for k = 1:n_region
subplot(1,n_region,k);
imshowpair(patch_hsv3{k},patch_bw{k},'montage');
end

%CMD input Promt
selector = input('Positive Cluster NO =');

patch_hsv3_POS = patch_hsv3{selector};
patch_bw_POS = patch_bw{selector};

patch_hsv3_NEG{n_region-1,1} = [];
patch_bw_NEG{n_region-1,1} = [];
inner_counter = 1;
for i = 1:n_region    
    if(i ~= selector)        
        patch_hsv3_NEG{inner_counter,1} = patch_hsv3{i};
        patch_bw_NEG{inner_counter,1} = patch_bw{i};
        inner_counter = inner_counter+1;
    end
end
inner_counter = 1;

DATA_DIR = 'C:\Users\Rattachai\Desktop\Matlab_exp\Segmented Data\';
filename_POSpatch_hsv3 = strcat(DATA_DIR,'patch_hsv3_POS_',int2str(image_k));
filename_NEGpatch_hsv3 = strcat(DATA_DIR,'patch_hsv3_NEG_',int2str(image_k));
filename_POSpatch_bw = strcat(DATA_DIR,'patch_bw_POS_',int2str(image_k));
filename_NEGpatch_bw = strcat(DATA_DIR,'patch_bw_NEG_',int2str(image_k));

save(filename_POSpatch_hsv3,'patch_hsv3_POS');
save(filename_NEGpatch_hsv3,'patch_hsv3_NEG');
save(filename_POSpatch_bw,'patch_bw_POS');
save(filename_NEGpatch_bw,'patch_bw_NEG');

clear; clc;




