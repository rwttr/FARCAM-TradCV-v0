
IMG_dir = 'C:\Users\Rattachai\Desktop\Image Acquisition 2\nexus\L1_600x800\';
n_region = 5;

image_k = 80; %image_no

[patch_hsv3,patch_bw,ctVal,~] = kmeansSeg2(IMG_dir,image_k,n_region);

figure();
for k = 1:n_region
subplot(1,n_region,k);
imshowpair(patch_hsv3{k},patch_bw{k,1},'montage');
end

%CMD input Promt
selector = input('Positive Cluster NO =');

patch_hsv3_POS{1,1} = patch_hsv3{selector};
patch_hsv3_POS{1,2} = patch_bw{selector,2};
patch_bw_POS{1,1} = patch_bw{selector,1};
patch_bw_POS{1,2} = patch_bw{selector,2};

patch_hsv3_NEG{n_region-1,2} = [];
patch_bw_NEG{n_region-1,2} = [];

inner_counter = 1;
for i = 1:n_region    
    if(i ~= selector)        
        patch_hsv3_NEG{inner_counter,1} = patch_hsv3{i};
        patch_hsv3_NEG{inner_counter,2} = patch_bw{i,2};
        patch_bw_NEG{inner_counter,1} = patch_bw{i,1};
        patch_bw_NEG{inner_counter,2} = patch_bw{i,2};
        inner_counter = inner_counter+1;
    end
end
inner_counter = 1;

DATA_DIR = 'C:\Users\Rattachai\Desktop\Matlab_exp\patch_nexus_600x800_L1\';
filename_POSpatch_hsv3 = strcat(DATA_DIR,'POS_hsv3\patch_hsv3_POS_',int2str(image_k));
filename_NEGpatch_hsv3 = strcat(DATA_DIR,'NEG_hsv3\patch_hsv3_NEG_',int2str(image_k));
filename_POSpatch_bw = strcat(DATA_DIR,'POS_bw\patch_bw_POS_',int2str(image_k));
filename_NEGpatch_bw = strcat(DATA_DIR,'NEG_bw\patch_bw_NEG_',int2str(image_k));

save(filename_POSpatch_hsv3,'patch_hsv3_POS');
save(filename_NEGpatch_hsv3,'patch_hsv3_NEG');
save(filename_POSpatch_bw,'patch_bw_POS');
save(filename_NEGpatch_bw,'patch_bw_NEG');

clear; clc;




