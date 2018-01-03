% 2

% Detect tree trunk left and right straight line
%   1. SHT detect line segments
%   2. k-mens separate x-axis point
%   3. Least-Square line left/right side

%  *** RUN AFTER test_illumination.m

% 1. ----------------------------------------------------------------------
% Standard Hough Transform detecting tree trunk
% rho = x*cos(theta) + y*sin(theta)

HOUGH_VOTE = 8;

%Hough Transform
HOUGH_THETA = 15; % limit Thera (vertical line) degree
[Hc,Tc,Rc] = hough(I_canny,'theta',-HOUGH_THETA:0.01:HOUGH_THETA);
[Hs,Ts,Rs] = hough(I_canny,'theta',-HOUGH_THETA:0.01:HOUGH_THETA);

%Find 4 peaks in the Hough transform matrix, H,
P_sobel = houghpeaks(Hs, HOUGH_VOTE,'threshold',ceil(0.5*max(Hs(:))));
P_canny = houghpeaks(Hc, HOUGH_VOTE,'threshold',ceil(0.5*max(Hc(:))));

%Display Hough Vote & Peak Point
figure('Name','Hough map and peak points');

% Sobel Edge
subplot(1,2,1);
    imshow(imadjust(mat2gray(Hs)),[],...
            'XData',Ts,...
            'YData',Rs,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)');
    ylabel('\rho');
    title('Sobel Edges');
hold on
    xs = Ts(P_sobel(:,2));
    ys = Rs(P_sobel(:,1));
    plot(xs,ys,'s','color','red');
axis normal
axis on

% Canny Edge
subplot(1,2,2);
    imshow(imadjust(mat2gray(Hc)),[],...
            'XData',Tc,...
            'YData',Rc,...
            'InitialMagnification','fit');
    xlabel('\theta (degrees)')
    ylabel('\rho')
hold on
    title('Canny Edges');
    xc = Tc(P_canny(:,2));
    yc = Rc(P_canny(:,1));
    plot(xc,yc,'s','color','red');
axis on
axis normal


%Plot Hough Peak line segments
lines_sobel = houghlines(I_sobel,Ts,Rs,P_sobel);
lines_canny = houghlines(I_canny,Tc,Rc,P_canny);

figure('Name','Detected line sengments')
% Canny lines
subplot(1,2,2);
imshow(I_canny)
hold()
max_len = 0;
for k = 1:length(lines_canny)   
   xyc = [lines_canny(k).point1; lines_canny(k).point2];
   plot(xyc(:,1),xyc(:,2),'LineWidth',1,'Color','green');
   
   % Plot beginnings and ends of lines
   plot(xyc(1,1),xyc(1,2),'x','LineWidth',1,'Color','blue');
   plot(xyc(2,1),xyc(2,2),'x','LineWidth',1,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines_canny(k).point1 - lines_canny(k).point2);
   if ( len > max_len )
      max_len = len;
      xy_long = xyc;
   end
end
title('Canny Edges');
axis on
axis normal
% Sobel lines
subplot(1,2,1); 
imshow(I_sobel)
hold()
max_len = 0;
for k = 1:length(lines_sobel)   
   xys = [lines_sobel(k).point1; lines_sobel(k).point2];
   plot(xys(:,1),xys(:,2),'LineWidth',1,'Color','green');
   
   % Plot beginnings and ends of lines
   plot(xys(1,1),xys(1,2),'x','LineWidth',1,'Color','blue');
   plot(xys(2,1),xys(2,2),'x','LineWidth',1,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines_sobel(k).point1 - lines_sobel(k).point2);
   if ( len > max_len )
      max_len = len;
      xy_long = xys;
   end
end
title('Sobel Edges');
axis on
axis normal

% 2 kmeans separate points
%--------------------------------------------------------------------------
% varriable declaration

%override use line_sobel
lines_canny = lines_sobel;

rhodata(length(lines_canny),1) = zeros;
lines_canny(1).lineclus_idx = zeros;   %add new field to lines_canny struct

%read out rho from struct to column vector
for k = 1:length(lines_canny)
    rhodata(k,1) = lines_canny(k).rho;
end

% K-means 2 cluster of rho value
[lineclus_idx,rhocen] = kmeans(rhodata,2);

k1 = 1;
k2 = 1;
for k = 1:length(lines_canny)
    lines_canny(k).lineclus_idx = lineclus_idx(k,1);
    
    if(lineclus_idx(k,1) == 1)
        point_line1(k1,:) = lines_canny(k).point1(1,:);
        sumrho_1(k1) = lines_canny(k).rho;
        point_line1(k1+1,:) = lines_canny(k).point2(1,:);
        sumrho_1(k1+1) = lines_canny(k).rho;
        k1 = k1+2;
    end
    
    if(lineclus_idx(k,1) == 2)
        point_line2(k2,:) = lines_canny(k).point1(1,:);
        sumrho_2(k2) = lines_canny(k).rho;
        point_line2(k2+1,:) = lines_canny(k).point2(1,:);
        sumrho_2(k2+1) = lines_canny(k).rho;
        k2 = k2+2;
    end
    
end
% point_line1 contain points in cluster 1
% point_line2 contain points in cluster 2

Eq1 = [ones(length(point_line1),1) point_line1(:,1)] \ point_line1(:,2);    
Eq2 = [ones(length(point_line2),1) point_line2(:,1)] \ point_line2(:,2); 

figure('Name','Least-Square line');
imshow(I_canny);
hold on;
scatter(point_line1(:,1),point_line1(:,2)); lsline;
scatter(point_line2(:,1),point_line2(:,2)); lsline;
axis on;
axis ([0 size(I_hsv,2) 0 size(I_hsv,1)] )

offset_left = 1;
offset_right = 1;

line_left = [zeros(size(I_hsv,1),1 ) (1:size(I_hsv,1))'];
line_right = line_left;

if( mean(sumrho_1) < mean(sumrho_2) ) %Eq1 = Left
    for k = 1:size(line_left,1)
        line_left(k,1) = floor( (line_left(k,2) - Eq1(1)) / Eq1(2) )...
                        - offset_left;
        line_right(k,1) = floor( (line_right(k,2) - Eq2(1)) / Eq2(2))...
                        + offset_right;
    end
end

if( mean(sumrho_1) > mean(sumrho_2) ) %Eq1 = rightr
    for k = 1:size(line_left,1)
        line_left(k,1) = floor( (line_left(k,2) - Eq2(1)) / Eq2(2) )...
                        - offset_left;
        line_right(k,1) = floor( (line_right(k,2) - Eq1(1)) / Eq1(2))...
                        + offset_right;
    end
end

tree_width = line_right - line_left;

figure('Name','Detected Tree line');
imshow(I_rgb);
hold on
plot(line_left(:,1),line_left(:,2),'color','red');
plot(line_right(:,1),line_right(:,2),'color','red');
axis normal;

%{
% -------------------------------------------------------------------------
% 2. Seperate left/right 
    %if xleft & xright collide need some rotation
    
%pre allocation before loops 
% dat_points store [x y]    
dat_points(2*length(lines_canny),2) = zeros;

%Copy point1, point2 from houghlines return structure
for k = 1:length(lines_canny)
    % copy x
    dat_points(k,1) = lines_canny(k).point1(1,1);
    dat_points(k+length(lines_canny),1) = lines_canny(k).point2(1,1);
    %copy y
    dat_points(k,2) = lines_canny(k).point1(1,2);
    dat_points(k+length(lines_canny),2) = lines_canny(k).point2(1,2);
end







%k-means seperate p_left, p_right, Cen= centroid of each cluster
[idx,cen] = kmeans(dat_points(:,1),2);
cmid = (cen(1) + cen(2)) / 2;
    %pre allocate before loop
    %x_clus1(sum(idx(:)==1),1) = zeros;
    %x_clus2(sum(idx(:)==2),1) = zeros;
k1=1;
k2=1;
for k = 1:size(idx)    
    if idx(k) == 1        
        x_clus1(k1,:) = dat_points(k,:);k1 = k1+1;
    end    
    if idx(k) == 2        
        x_clus2(k2,:) = dat_points(k,:);k2 = k2+1;
    end
end

% left/ right decision
if ( mean(x_clus1(:,1) < cmid))
    p_left  = x_clus1;
    p_right = x_clus2;
else
    p_left  = x_clus2;
    p_right = x_clus1;
end

%clear x_clus1 x_clus2 k1 k2 k


% 3.-----------------------------------------------------------------------
% The \ operator performs a least-squares regression. mldivide, \
% linear equations, X*m + e = Y. e:y-intercept
% m = X\Y
% m = mldivide(X,Y)

% finding y-intercept 
% X = [ones(length(x),1) x]; padd one in 1st coloum of X
% b = X\y

%Line equation (1) = yintercept, (2)=slope
EqL = [ones( size(p_left,1) ,1) p_left(:,1)]  \ p_left(:,2);    
EqR = [ones( size(p_right,1),1) p_right(:,1)] \ p_right(:,2); 

figure('Name','Least-Square line');
imshow(I_sobel);
hold on;
scatter(p_left(:,1),p_left(:,2)); lsline;
scatter(p_right(:,1),p_right(:,2)); lsline;
axis on;
axis ([0 size(I_hsv,2) 0 size(I_hsv,1)] )


offset_left = 10;
offset_right = 10;

line_left = [zeros(size(I_hsv,1),1 ) (1:size(I_hsv,1))'];
line_right = line_left;

for k = 1:size(line_left,1)
    line_left(k,1) = floor( (line_left(k,2) - EqL(1)) / EqL(2) )...
        - offset_left;
    line_right(k,1) = floor( (line_right(k,2) - EqR(1)) / EqR(2))...
        + offset_right;
end

tree_width = line_right - line_left;

figure('Name','Detected Tree line');
imshow(I_rgb);
hold on
plot(line_left(:,1),line_left(:,2),'color','red');
plot(line_right(:,1),line_right(:,2),'color','red');
axis normal;

%}

%output line_left, line_right, tree_width


