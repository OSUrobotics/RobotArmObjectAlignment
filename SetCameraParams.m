function [ cameras ] = SetCameraParams( cam )
%SetCameraParams Summary of this function goes here
%   Copy the parameters from the Kinect (as output by ROS)
%
%   Use the MATLAB camera tool box cameraParameters
% #########CAMERA 1 #####################
% DEPTH IMAGE PARAMETERS
% header: 
%   seq: 7
%   stamp: 
%     secs: 1508524793
%     nsecs: 648356774
%   frame_id: camera1_depth_optical_frame
% height: 360
% width: 480
% distortion_model: plumb_bob
% D: [0.0, 0.0, 0.0, 0.0, 0.0]
% K: [448.0877685546875, 0.0, 236.62889099121094, 0.0, 448.0877685546875, 179.5, 0.0, 0.0, 1.0]
% R: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
% P: [448.0877685546875, 0.0, 236.62889099121094, -0.058705687522888184, 0.0, 448.0877685546875, 179.5, -0.00016042569768615067, 0.0, 0.0, 1.0, 0.00042840142850764096]
% binning_x: 0
% binning_y: 0
% roi: 
%   x_offset: 0
%   y_offset: 0
%   height: 0
%   width: 0
%   do_rectify: False
K1Depth = [ 448.0877685546875, 0.0, 236.62889099121094; ...
       0.0, 448.0877685546875, 179.5; ...
       0.0, 0.0, 1.0];
K2Depth = [451.8108825683594, 0.0, 226.99929809570312; ...
      0.0, 451.8108825683594, 177.14549255371094; ...
      0.0, 0.0, 1.0];
D1Image = [-0.09165161848068237, 0.06964036077260971, -0.0010055634193122387, 0.00047066836850717664, 0.0];
D2Image = [-0.07281754910945892, 0.032828573137521744, 0.00014048755110707134, -0.0016058818437159061, 0.0];
K1Image = [625.9136962890625, 0.0, 326.21539306640625;...
           0.0, 631.4508666992188, 223.1887664794922;...
           0.0, 0.0, 1.0] ;
K2Image = [629.7976684570312, 0.0, 294.1859436035156;...
           0.0, 635.0286254882812, 238.6531982421875;...
           0.0, 0.0, 1.0] ;

P1Depth = [448.0877685546875, 0.0, 236.62889099121094, -0.058705687522888184 ;...
           0.0, 448.0877685546875, 179.5, -0.00016042569768615067 ;...
           0.0, 0.0, 1.0, 0.00042840142850764096];
P2Depth = [451.8108825683594, 0.0, 226.99929809570312, -0.05845455452799797 ;...
           0.0, 451.8108825683594, 177.14549255371094, -0.00021050695795565844 ;...
           0.0, 0.0, 1.0, 0.00017856800695881248];
       
if cam == 1
    KDepth = K1Depth;
    KImage = K1Image;
    DImage = D1Image;
    PDepth = P1Depth;
else
    KDepth = K2Depth;
    KImage = K2Image;
    DImage = D2Image;
    PDepth = P2Depth;
end

% Save
cameras = struct;
cameras.PDepth = PDepth;

% Undo to get fc, etc
fc = [KDepth(1,1) KDepth(2,2)];
skew = KDepth(1,2) / fc(1);
cc = [KDepth(1,3) KDepth(2,3)];

cameras.depthfc = fc;
cameras.depthcc = cc;

intrinsicMDepth = [ fc(1) 0 0; skew fc(2) 0; cc(1) cc(2) 1 ];

% RGB
fc = [KImage(1,1) KImage(2,2)];
skew = KImage(1,2) / fc(1);
cc = [KImage(1,3) KImage(2,3)];

cameras.imagefc = fc;
cameras.imagecc = cc;
intrinsicMImage = [ fc(1) 0 0; skew fc(2) 0; cc(1) cc(2) 1 ];

cameras.depthCam = cameraParameters( 'IntrinsicMatrix', intrinsicMDepth );
cameras.imageCam = cameraParameters( 'IntrinsicMatrix', intrinsicMImage, ...
                                     'RadialDistortion', DImage(1:3), ...
                                     'TangentialDistortion', DImage(4:5)');
end

