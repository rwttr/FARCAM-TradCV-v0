utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos', ...
    'html', 'KinectForWindows');
addpath(utilpath);

% The Kinect for Windows Sensor shows up as two separate devices in IMAQHWINFO.
info = imaqhwinfo('kinect');



imaqtool



%logitech webcam
webcamlist
webcam1 = webcam(1);
preview(webcam1);