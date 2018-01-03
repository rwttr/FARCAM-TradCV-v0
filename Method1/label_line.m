
%input = im_clusxx

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


tap_edge = edge(sel_clus_filt_label,'Canny',0.5);
imshow(tap_edge);

N_LINE = 2; 
LINE_ANGLE_MAX = -60;
LINE_ANGLE_MIN = -30;

[Hl,Tl,Rl] = hough(tap_edge,'theta',LINE_ANGLE_MAX:0.01:LINE_ANGLE_MIN);
P_line = houghpeaks(Hl, N_LINE,'threshold',ceil(0.5*max(Hl(:))));

imshow(imadjust(mat2gray(Hl)),[],...
            'XData',Tl,...
            'YData',Rl,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)');
    ylabel('\rho');
    title('Line Edges');
hold on
    xl = Tl(P_line(:,2));
    yl = Rl(P_line(:,1));
    plot(xl,yl,'s','color','red');
axis normal
axis on

lines_tap = houghlines(tap_edge,Tl,Rl,P_line);
imshow(tap_edge+I_hsv3)
hold()
max_len = 0;
for k = 1:length(lines_tap)   
   xyl = [lines_tap(k).point1; lines_tap(k).point2];
   plot(xyl(:,1),xyl(:,2),'LineWidth',1,'Color','green');
   
   % Plot beginnings and ends of lines
   plot(xyl(1,1),xyl(1,2),'x','LineWidth',1,'Color','blue');
   plot(xyl(2,1),xyl(2,2),'x','LineWidth',1,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines_tap(k).point1 - lines_tap(k).point2);
   if ( len > max_len )
      max_len = len;
      xyl_long = xyl;
   end
end
title('Line Edges');
axis on
axis normal


