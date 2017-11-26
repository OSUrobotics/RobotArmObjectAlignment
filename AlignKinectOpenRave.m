function [ M, R, T, S ] = AlignKinectOpenRave( xyzArm, uvdKinect )
% AlignKinectOpenRave - Align arm with point cloud
%    INPUT
%      xyzArm: Points on the arm/known 3D points 
%      uvdKinect: Point cloud
%    OUTPUT:
%  The matrix (rotation + translation + scale) that best aligns the 3D
%  points from the kinect point cloud with the barrett arm

[~,~,transform] = procrustes( xyzArm, uvdKinect, 'reflection', false );

R = eye(4,4);
T = eye(4,4);
S = eye(4,4);

R(1:3,1:3) = transform.T';
for k = 1:3
    S(k,k) = transform.b;
end

T(1:3,4) = transform.c(1,1:3);

Z = transform.b * uvdKinect * transform.T + transform.c;

M = T * R * S;

Z2Full = M * [uvdKinect'; ones(1,size(uvdKinect,1))];
Z2 = Z2Full(1:3,:)';


end

