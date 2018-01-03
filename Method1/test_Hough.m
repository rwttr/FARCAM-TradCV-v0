% 2

% Detect tree trunk left and right straight line
%   1. SHT detect line segments
%   2. k-mens separate x-axis point
%   3. Least-Square line left/right side

%  *** RUN AFTER test_illumination.m


% 1. ----------------------------------------------------------------------
% Standard Hough Transform detecting tree trunk
% rho = x*cos(theta) + y*sin(theta)


%Hough Transform
Theta_angle = 20; % limit Thera (vertical line) degree
[Hc,Tc,Rc] = hough(I_canny,'theta',-Theta_angle:0.01:Theta_angle);
[Hs,Ts,Rs] = hough(I_sobel,'theta',-Theta_angle:0.01:Theta_angle);

%Find 2 peaks in the Hough transform matrix, H,
P_sobel = houghpeaks(Hs, 2,'threshold',ceil(0.5*max(Hs(:))));
P_canny = houghpeaks(Hc, 2,'threshold',ceil(0.5*max(Hc(:))));

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

%Sobel
lines_sobel = houghlines(I_canny,Ts,Rs,P_sobel);
max_len = 0;
figure('Name','Detected line sengments')

imshow(1-I_sobel)
hold()

for k = 1:length(lines_sobel)   
   xys = [lines_sobel(k).point1; lines_sobel(k).point2];
   plot(xys(:,1),xys(:,2),'LineWidth',2,'Color','green');
   
   % Plot beginnings and ends of lines
   plot(xys(1,1),xys(1,2),'x','LineWidth',2,'Color','blue');
   plot(xys(2,1),xys(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines_sobel(k).point1 - lines_sobel(k).point2);
   if ( len > max_len )
      max_len = len;
      xy_long = xys;
   end
end
axis on
axis normal

% -------------------------------------------------------------------------
% 2. Seperate left/right 
    %if xleft & xright collide need some rotation
    
%pre allocation before loops 
% dat_points store [x y]    
dat_points(2*length(lines_sobel),2) = zeros;

%Copy point1, point2 from houghlines return structure
for k = 1:length(lines_sobel)
    % copy x
    dat_points(k,1) = lines_sobel(k).point1(1,1);
    dat_points(k+length(lines_sobel),1) = lines_sobel(k).point2(1,1);
    %copy y
    dat_points(k,2) = lines_sobel(k).point1(1,2);
    dat_points(k+length(lines_sobel),2) = lines_sobel(k).point2(1,2);
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


%output line_left, line_right, tree_width


