%  idea tester

wavelength = 2;
orientation = 45;
[mag2,phase2] = imgaborfilt(I_hsv3,wavelength,orientation);
[mag4,phase4] = imgaborfilt(I_hsv3,wavelength*2,orientation);
[mag8,phase8] = imgaborfilt(I_hsv3,wavelength*4,orientation);
[mag16,phase16] = imgaborfilt(I_hsv3,wavelength*8,orientation);
% Normalize Gabor magnitude
normMAG2 = mag2 - min(mag2(:));
normMAG2 = normMAG2 ./ max(normMAG2(:));

normMAG4 = mag4 - min(mag4(:));
normMAG4 = normMAG4 ./ max(normMAG4(:));

normMAG8 = mag8 - min(mag8(:));
normMAG8 = normMAG8 ./ max(normMAG8(:));

normMAG16 = mag16 - min(mag16(:));
normMAG16 = normMAG16 ./ max(normMAG16(:));

% sum gabor (saturated at 1)
sumMAG = normMAG2 + normMAG4 + normMAG8 + normMAG16;
sumMAG(sumMAG >=1) = 1;
imshow(sumMAG);

sumMAG_c = imcomplement(sumMAG);
I_testDiff = I_hsv3-sumMAG_c;

% negative saturate at 0
I_testDiff(I_testDiff <=0) = 0;

imshow(I_testDiff);


figure('Name',['Wavelength=',num2str(wavelength),' Orientation=',num2str(orientation)]);
subplot(1,3,1);
imshow(I_hsv3);
title('Original Image');
subplot(1,3,2);
imshow(mag2+mag4)
title('Gabor magnitude');
subplot(1,3,3);
imshow(phase4,[]);
title('Gabor phase');



normMAG_c = imcomplement(normMAG);

I_testDiff1 = I_hsv3-normMAG_c;

imshow(normMAG_c);

imshow(I_hsv3);

imshowpair(I_testDiff,I_testDiff1,'montage');



gaborArray = gabor([2 4 8],[30 45 60]);
gaborMag = imgaborfilt(I_hsv3,gaborArray);
figure
subplot(1,3,1);


imshow(gaborMag(:,:,p),[]);
theta = gaborArray(p).Orientation;
lambda = gaborArray(p).Wavelength;
title(sprintf('Orientation=%d, Wavelength=%d',theta,lambda));
