%% Check the alignment algorithms
addpath('~/Documents/MATLAB/icp');

% Test code for using ICP to align two point clouds/meshes
dir = '/Users/cindygrimm/Dropbox/PointCloudAlignment/wheelchair_point_clouds/';
xyzRGB1 = dlmread(strcat(dir, 'wheelchair_cloud_000'));
xyzRGB2 = dlmread(strcat(dir, 'wheelchair_cloud_001'));

clf;
showPointCloud(xyzRGB1(:,1:3), xyzRGB1(:,4:6) / 255.0 );
hold on;
showPointCloud(xyzRGB2(:,1:3), xyzRGB2(:,4:6) / 255.0);

MAlign = AlignPointClouds(xyzRGB1(:,1:3), xyzRGB2(:,1:3));

xyzAlignFull = MAlign * [xyzRGB2(:,1:3)'; ones(1,size(xyzRGB2,1))];
xyzAlign = xyzAlignFull(1:3,:)';

showPointCloud(xyzAlign, [0.5 0.5 0.5]);


%% Test code for known 3D points to known 3D points
xyzTest = [ 1, 0, 0; 0, 1, 0; 0, 0, 1; 1 1 1; 0 1 1];

T = [0.2, 0.7, 0.1];
S = [1.2, 1.2, 1.2];
R = [ 0.2, 0.1, 0.7, pi/3];

TM = eye(4,4);
TM(1:3,4) = T';
SM = eye(4,4);
for k = 1:3
    SM(k,k) = S(k);
end
RM = eye(4,4);
RM(1:3,1:3) = angle2dcm( R(1), R(2), R(3) );
M = TM * RM * SM;

uvdFullTest = M * [xyzTest'; ones(1,size(xyzTest,1))];
uvdTest = uvdFull(1:3,:)';

MBack = AlignKinectOpenRave(xyzTest, uvdTest);

showPointCloud(xyz);
