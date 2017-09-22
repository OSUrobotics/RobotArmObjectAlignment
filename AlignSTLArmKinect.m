%% Align the point cloud to the hand/arm and the object to the point cloud
function [matPC, matObj] = AlignSTLArmKinect( dir, fnameBase, fnameObjSTL )

fprintf('Aligning %s, Object %s\n', strcat(dir, fnameBase), fnameObjSTL );
objTransformsFolder = 'hand_object_transformation/';

fnameKinect = '_pointcloud.csv';
fnameKinectClipped = '_pointcloud_clipped.csv';
fnameRobotSTL = '.stl';
fnameKinectImage = '_dotted.png';
fnameObjFinalMatrix = '_obj_align_matrix.txt';
fnamePointCloudFinalMatrix = '_pointcloud_align_matrix.txt';
fnameObjMatrix = '_object_transformation.txt';

% File names that are the same for all
fnameRobotHandMask = 'robotArmHandMask.txt';
fnameRobotBaseMask = 'robotArmBaseMask.txt';
fnameMasterMatrix = 'MasterMatrix.txt';

% The master alignment matrix calculated by MasterMatrixAlignment.m
M = dlmread( strcat(dir, fnameMasterMatrix) );

% Read in kinect point cloud
% Multiply by master matrix to roughly align
% Cull out background points by calculating distance between point cloud
% and stl file (icp might do this)
%   Clip by bounding box of hand first maybe
% Kmeans clustering: Is the point in the point cloud closer to the hand or
% to the object stl
%   Ran icp with object -> distances for point
%                r
%    Assign to closest
%  Cull by color

objSTLOrig = stlread( strcat(dir, fnameObjSTL ) );
objSTLOrig.vertices = objSTLOrig.vertices * 0.001;
objSTL = objSTLOrig;

%% Read and clean up data
% Cycle through the three test arm positions

% The stl/ply file for the arm
armSTL = stlread( strcat(dir, fnameBase, fnameRobotSTL ) );
handMask = dlmread( strcat(dir, fnameRobotHandMask ) );
handMask = handMask == 1;
baseMask = dlmread( strcat(dir, fnameRobotBaseMask ) );
baseMask = baseMask == 1;

% The alignment matrix for the object
matObj = dlmread( strcat(dir, objTransformsFolder, fnameBase, fnameObjMatrix) );
matObj = reshape( matObj, [4,4] )';
objSTL.vertices = matObj * [objSTLOrig.vertices'; ones(1,size(objSTL.vertices,1))];
objSTL.vertices = objSTL.vertices(1:3,:)';

%% The kinect point cloud 
kinect = csvread( strcat(dir, fnameBase, fnameKinect) );
kinect(:,4:6) = kinect(:,4:6) / 255;
% Picture from the kinect
kinectImage = imread( strcat(dir, fnameBase, fnameKinectImage) );

% Move the point cloud using M
kinectXYZFull = Move(kinect, M);

%% Cull out the stl vertices that are the hand and the base
bboxHand = [ min( armSTL.vertices(handMask,:) ); max( armSTL.vertices(handMask,:) ) ];    
bboxBase = [ min( armSTL.vertices(baseMask,:) ); max( armSTL.vertices(baseMask,:) ) ];    

% Get all the vertices that weren't painted
handMask = InsideBBox( armSTL.vertices, bboxHand, 1.01 );
baseMask = InsideBBox( armSTL.vertices, bboxBase, 1.01 );
armMask = ~handMask & ~baseMask;

% Bounding box arm
bboxArm = [ min( armSTL.vertices(armMask,:) ); max( armSTL.vertices(armMask,:) ) ];

% Bounding box of the object
bboxObj = [ min( objSTL.vertices ); max( objSTL.vertices ) ];

fprintf('Initial alignment of point cloud to arm\n');
% Show the picture
figure(1);
clf
imshow(kinectImage);

% Check the masking of the arm
figure(2);
clf;
showPointCloud(armSTL.vertices(baseMask,:), [0.0 0.0 0] );
hold on;
showPointCloud(armSTL.vertices(handMask,:), [1 0 0] );
showPointCloud(armSTL.vertices(armMask,:), [0 1 0] );

%% Cull out the point cloud that is not table/object
kinectHandMask = InsideBBox( kinectXYZFull, bboxHand, 1.1 );
kinectArmMask = InsideBBox( kinectXYZFull, bboxArm, 1.1 );
kinectMask = kinectHandMask | kinectArmMask;

% Check the masking of the kinect data
figure(3);
clf;
showPointCloud(kinectXYZFull(:,1:3), kinectXYZFull(:,4:6));
hold on;
showPointCloud(kinectXYZFull(kinectHandMask,1:3), [1 0 0] );
showPointCloud(kinectXYZFull(kinectArmMask,1:3), [0 1 0] );

%% ICP align clipped clouds
ptsResampleArm = GetPtsForICP( armSTL, armMask, 60 );
armSTLMaskICP = InsideBBox( ptsResampleArm, bboxArm, 0.65 );
armKinectMaskICP = InsideBBox( kinectXYZFull(:, 1:3), bboxArm, 0.65 );    
mFix = AlignPointClouds( ptsResampleArm( armSTLMaskICP, :), kinectXYZFull( armKinectMaskICP, 1:3 ) );

kinectXYZAligned = Move( kinectXYZFull, mFix );
matPC = mFix * M;

% Check the icp alignment and masking    
figure(4);
clf;
showPointCloud( ptsResampleArm( armSTLMaskICP, : ), [1 0 0] );
hold on;
showPointCloud( kinectXYZAligned( armKinectMaskICP, 1:3 ), [0 1 0] );
showPointCloud(kinectXYZAligned(kinectMask,1:3), kinectXYZAligned(kinectMask,4:6));
RenderSTL( armSTL, -1, true, [0.8 0.8 0.2] );


fprintf('Initial aligning of object to point cloud\n');

%% Align the object
ptsResampleObj = GetPtsForICP( objSTL, objSTL.vertices(:,1) > -10, 100 );
objKinectMaskICP = InsideBBox( kinectXYZAligned(:, 1:3), bboxObj, 1.2 );    
mFix = AlignPointClouds( kinectXYZAligned( objKinectMaskICP, 1:3 ), ptsResampleObj );
matObj = mFix * matObj;

objSTL.vertices = Move( objSTL.vertices, mFix );

% Check the icp alignment and masking of the object   
figure(5);
clf;
showPointCloud( ptsResampleObj, [1 0 0] );
hold on;
showPointCloud( kinectXYZAligned( objKinectMaskICP, 1:3 ), [0 1 0] );
showPointCloud(kinectXYZAligned(kinectMask,1:3), kinectXYZAligned(kinectMask,4:6));
RenderSTL( objSTL, -1, true, [0.2 0.2 0.8] );

%% Render the arm, the point cloud, and the picked points
RenderSTL( armSTL, 6, false, [0.8 0.8 0.2] );
RenderSTL( objSTL, -1, true, [0.2 0.2 0.8] );
% The picked out points as big X's
%plot3( pickedPts(:,armRange(1)), pickedPts(:,armRange(2)), pickedPts(:,armRange(3)),  'Xk', 'MarkerSize', 20, 'LineWidth', 5 );
%plot3( kinectPts(:,1), kinectPts(:,2), kinectPts(:,3),  'Xb', 'MarkerSize', 20, 'LineWidth', 5 );


fprintf('Align both at the same time\n');
%% Now align both together
[matPCAlign, matObjAlign] = AlignHandAndObject( armSTL, objSTL, handMask, armMask, kinectXYZAligned );
matObj = matObjAlign * matObj;
matPC = matPCAlign * matPC;

kinectXYZAligned = Move( kinect, matPC );
objSTL.vertices = Move( objSTLOrig.vertices, matObj );

%% Write out the clipped point cloud and alignment matrix
csvwrite( strcat(dir, fnameBase, fnameKinectClipped), kinectXYZAligned( kinectMask, : ) );    
dlmwrite( strcat( dir, objTransformsFolder, fnameBase, fnameObjFinalMatrix ), matObj, ' ' );
dlmwrite( strcat( dir, objTransformsFolder, fnameBase, fnamePointCloudFinalMatrix ), matPC, ' ' );
fprintf('Wrote matrix files %s %s point cloud %s\n', fnameObjFinalMatrix, fnamePointCloudFinalMatrix, fnameKinectClipped);

% Final check
RenderSTL( armSTL, 7, false, [0.8 0.8 0.2] );
RenderSTL( objSTL, -1, true, [0.2 0.2 0.8] );

% Colors are in the original data
showPointCloud(kinectXYZAligned(kinectMask,1:3), kinectXYZAligned(kinectMask,4:6));

end
