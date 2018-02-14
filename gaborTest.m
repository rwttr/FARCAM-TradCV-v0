

wavelength = [2 4 8];
orientation = [0 45 90];

g = gabor(wavelength,orientation);


for p = 1:length(g)
    subplot(3,3,p);
    imshow(real(g(p).SpatialKernel),[]);
    lambda = g(p).Wavelength;
    theta  = g(p).Orientation;
    title(sprintf('Re[h(x,y)], \\lambda = %d, \\theta = %d',lambda,theta));
end

test1 = g(1).SpatialKernel;
test2 = g(2).SpatialKernel;
test3 = g(3).SpatialKernel;
test4 = g(4).SpatialKernel;
%imagesc(real(test));

ftest1 = fft2(test1);
ftest2 = fft2(test2);
ftest3 = fft2(test3);
ftest4 = fft2(test4);

imagesc(abs(fftshift(ftest1)));
hold on;
imagesc(abs(fftshift(ftest2)));
imagesc(abs(fftshift(ftest3)));
imagesc(abs(fftshift(ftest4)));



imagesc(abs(fftshift(ftest1)));

outMag = imgaborfilt(I_smooth,g);

outSize = size(outMag);
outMag = reshape(outMag,[outSize(1:2),1,outSize(3)]);
figure, montage(outMag,'DisplayRange',[]);
title('Montage of gabor magnitude output images.');


%{
 Wavelength of sinusoid, specified as a numeric scalar or vector, in px/cycle.
 Orientation of filter in degrees, a numeric scalar in the range [0 180], 
 where the orientation is defined as the normal direction to the sinusoidal plane wave
%}
