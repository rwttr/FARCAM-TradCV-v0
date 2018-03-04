function [ avgGrad ] = avgGradDir( I_filtered,I_bw )

[~,Gdir] = imgradient(I_filtered);
Gdir_masked = Gdir.*I_bw;
%avgGrad = mean(mean(Gdir_masked));
qGdir = round(Gdir_masked,0);
avgGrad = mean( nonzeros(qGdir) );




end











