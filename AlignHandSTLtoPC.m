function [ matAdjustSTL, stlVsAligned ] = AlignHandSTLtoPC( armSTL, handMask, wristAndArmMask, xyzKinect )
%AlignHandSTLtoPC Move the stl file to the vertices
%   Essentially ICP 
%
%  INPUT:
%    stlIn - the hand/arm stl
%    hand & arm Mask - stl vertices for the hand/arm
%    xyzKinect - the point cloud aligned with the table
%
%  OUTPUT:
%    matAdjustSTL - matrix to move the stl to the point cloud
%    stlVsAligned - move the stl vertices


%% Cull out the stl vertices that are the hand and the arm
bboxHand = [ min( armSTL.vertices(handMask,:) ); max( armSTL.vertices(handMask,:) ) ];    
bboxArm = [ min( armSTL.vertices(wristAndArmMask,:) ); max( armSTL.vertices(wristAndArmMask,:) ) ];    

% Get all the vertices that weren't painted
handMask = InsideBBox( armSTL.vertices, bboxHand, 1.01 );
armMask = InsideBBox( armSTL.vertices, bboxArm, 1.01 );
armMask = armMask & ~handMask;

% Put all the point cloud vs into one collection
%   but keep track of which one is which
xyzTrim = [];
whichCam = [];
for cam = 1:length( xyzKinect )
    xyzTrimCam = TrimPC( xyzKinect{cam} );
    xyzTrim = [ xyzTrim; xyzTrimCam ];
    whichCam = [ whichCam; zeros( size(xyzTrim,1 ), 1 )+ cam];
end

fprintf('Initial alignment of point cloud to arm\n');
% Check the masking of the point cloud/arm and the alignment of the point cloud with
% the STL
figure(2);
clf
RenderSTL( armSTL, -1, true, [0.8 0.8 0.2] );
hold on;
pcshow( xyzTrim(:,1:3), xyzTrim(:,4:6) );

% Check the masking of the arm
pcshow(armSTL.vertices(handMask,:), [1 0 0] );
pcshow(armSTL.vertices(armMask,:), [0 1 0] );

%% Cull out the point cloud that is not table/object
kinectHandMask = InsideBBox( xyzTrim, bboxHand, 1.1 );
kinectArmMask = InsideBBox( xyzTrim, bboxArm, 1.1 );
kinectMask = kinectHandMask | kinectArmMask;
pcHandArm = xyzTrim( kinectMask, : );

%% ICP align clipped clouds
ptsResampleHand = GetPtsForICP( armSTL, handMask, 3 );
[~, idsOverTable] = TrimPC( armSTL.vertices );
armMaskTrimmed = armMask;
armMaskTrimmed( ~idsOverTable ) = 0;
ptsResampleArm = GetPtsForICP( armSTL, armMaskTrimmed, 30 );
ptsArmOverTable = [TrimPC( ptsResampleArm ); ptsResampleHand];

%% Show trimmed point clouds
clf
pcshow( pcHandArm(:,1:3), pcHandArm(:,4:6) );
hold on;
pcshow( ptsArmOverTable(:,1:3) );

% Align
fprintf('Aligning\n');
matAdjustSTL = AlignPointClouds( pcHandArm( :, 1:3 ), ptsArmOverTable );

stlVsAligned = Move( armSTL.vertices, matAdjustSTL );

armSTL.vertices = stlVsAligned;
figure(2);
clf
RenderSTL( armSTL, -1, true, [0.8 0.8 0.2] );
hold on;
pcshow( pcHandArm(:,1:3), pcHandArm(:,4:6) );
end

